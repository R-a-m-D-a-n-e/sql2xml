drop table R_Country;
create table R_Country as select * from Country;

-------------------------------------------------------------- T_CountryAbs 

drop type T_CountryAbs force;
/
create or replace  type T_CountryAbs as OBJECT (
   id_  NUMBER,
   not INSTANTIABLE member function toXML return XMLType
) not FINAL not INSTANTIABLE
/

drop type Ens_CountryAbs force;
/
CREATE type Ens_CountryAbs as TABLE of T_CountryAbs;
/

-------------------------------------------------------------- Geo 
drop type T_Geo force;
/
create or replace  type T_Geo as OBJECT (
   mountain_desert      Ens_Relief,
   island        Ens_Island,
   member function toXML return XMLType,
   member PROCEDURE listMountainDesertIsland(code in VARCHAR),
   member function higherMountain return NUMBER,
   STATIC FUNCTION factory(code in VARCHAR) return T_Geo
)
/

-- Geo 
create or replace type body T_Geo as
 member function toXML return XMLType is
    childs Ens_XMLType;
    output XMLType;
   begin
      output := XMLType.createxml('<geo/>');

      select md.toXML()
      bulk collect into childs
      from table(mountain_desert) md;
      output := addListChildsXml(output,'geo',childs);

      childs.Delete;

      select isl.toXML()
      bulk collect into childs
      from table(island) isl;
      output := addListChildsXml(output,'geo',childs);

      return output;
   end toXML;

   member function higherMountain return NUMBER is
    output NUMBER;
    tmp T_Mountain;
   begin

      select max(TREAT(deref(value(m)) As T_Mountain).height) into output
      from table(self.mountain_desert) m
      where deref(value(m)) is of type (T_Mountain);

      if(output is null)THEN
        return 0;
      end if;

      return output;
   end higherMountain;

   member PROCEDURE listMountainDesertIsland(code in VARCHAR) is
    mountain_desert Ens_Relief;
    island        Ens_Island;
    BEGIN
      select * bulk collect into mountain_desert from( 
      select ref(r) 
      from LesReliefs r,R_Geo_mountain m
      where r.name=m.mountain and code=m.country
      union
      select ref(r)
      from LesReliefs r,R_Geo_desert d
      where r.name=d.desert and code=d.country
      union
      select VALUE(b)
      from table(self.mountain_desert) b
      );
      
      self.mountain_desert:=mountain_desert;

      select ref(i) 
      bulk collect into island
      from LesIslands i,R_Geo_island g
      where i.name=g.island and code=g.country;
      
      self.island:=island;
    END listMountainDesertIsland;

   STATIC FUNCTION factory(code in VARCHAR) return T_Geo IS
    output T_Geo;
   begin
      output := T_Geo(Ens_Relief(),Ens_Island());
      output.listMountainDesertIsland(code);
      return output;
   end factory;
end;
/
-------------------------------------------------------------- Country3
drop type T_Country3 force;
/
create or replace  type T_Country3 UNDER T_CountryAbs (
   name         VARCHAR2(60 Byte),
   geo          T_Geo,
   CONSTRUCTOR FUNCTION T_Country3(SELF IN OUT NOCOPY T_Country3, name in VARCHAR2,geo in T_Geo) RETURN SELF AS RESULT,
   overriding member function toXML return XMLType
) not FINAL
/

create or replace type body T_Country3 as
  CONSTRUCTOR FUNCTION T_Country3(SELF IN OUT NOCOPY T_Country3, name in VARCHAR2,geo in T_Geo) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    if(name is NULL) THEN
      raise_application_error( -20001,'les Args de T_Country3 ne respecte pas la DTD name CDATA #REQUIRED' );
    end if;

    SELF.name:=name;
    SELF.geo:=geo;

    return;
  END T_Country3;

  overriding member function toXML return XMLType is
    childs Ens_XMLType;
    output XMLType;
   begin

      select XMLELEMENT("country",XMLATTRIBUTES(name AS "name")) into output from DUAL;

      output := XMLType.appendchildxml(output,'countr', geo.toXML());

      return output;
   end toXML;
end;
/

-------------------------------------------------------------- Peak 
drop type T_Peak force;
/
create or replace  type T_Peak as OBJECT (
   height         NUMBER,
   CONSTRUCTOR FUNCTION T_Peak(SELF IN OUT NOCOPY T_Peak, height NUMBER) RETURN SELF AS RESULT,
   member function toXML return XMLType
)
/

-- Peak 
create or replace type body T_Peak as
  CONSTRUCTOR FUNCTION T_Peak(SELF IN OUT NOCOPY T_Peak, height NUMBER) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    if(height is NULL) THEN
      raise_application_error( -20001,'les Args de T_Peak ne respecte pas la DTD height CDATA #REQUIRED' );
    end if;

    SELF.height:=height;

    return;

  END T_Peak;

  member function toXML return XMLType is
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin
   
      if(SELF.height is NULL) THEN
        raise_application_error( -20001, height || ' ne respecte pas la DTD height CDATA #REQUIRED' );
      end if;
      
      select XMLELEMENT("Peak",XMLATTRIBUTES(height AS "height")) into output from DUAL;
      
      return output;
   end;
end;
/


-------------------------------------------------------------- Country4
drop type T_Country4 force;
/
create or replace  type T_Country4 under T_Country3(
   peak          T_Peak,
   CONSTRUCTOR FUNCTION T_Country4(SELF IN OUT NOCOPY T_Country4, name in VARCHAR2,geo in T_Geo) RETURN SELF AS RESULT,
   overriding member function toXML return XMLType
)
/

create or replace type body T_Country4 as
  CONSTRUCTOR FUNCTION T_Country4(SELF IN OUT NOCOPY T_Country4, name in VARCHAR2,geo in T_Geo) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    if(name is NULL) THEN
      raise_application_error( -20001,'les Args de T_Country4 ne respecte pas la DTD name CDATA #REQUIRED' );
    end if;

    SELF.name:=name;
    SELF.geo:=geo;
    SELF.peak:=T_Peak(geo.higherMountain());

    return;
  END T_Country4;
 overriding member function toXML return XMLType is
    output XMLType;
   begin
      output := (self AS T_Country3).toXML();
      output := XMLType.appendchildxml(output,'country', peak.toXML());

      return output;
   end toXML;
end;
/




-------------------------------------------------------------- ContCountries 
drop type T_ContCountries force;
/
create or replace  type T_ContCountries as OBJECT (
   border         Ens_Border,
   CONSTRUCTOR FUNCTION T_ContCountries(SELF IN OUT NOCOPY T_ContCountries,continent VARCHAR2, codeCountry VARCHAR2) RETURN SELF AS RESULT,
   member function toXML return XMLType
)
/

-- ContCountries 
create or replace type body T_ContCountries as
  CONSTRUCTOR FUNCTION T_ContCountries(SELF IN OUT NOCOPY T_ContCountries,continent VARCHAR2, codeCountry VARCHAR2) RETURN SELF AS RESULT IS
  BEGIN

    select * bulk collect into self.border from( 
      select T_Border(b.country2,b.length)
      from R_Borders b,R_Encompasses e
      where b.country1=codeCountry and e.country=b.country2 and e.continent=continent
      union
      select T_Border(b.country1,b.length)
      from R_Borders b,R_Encompasses e
      where b.country2=codeCountry and e.country=b.country1 and e.continent=continent
    );
    
    return;
  END T_ContCountries;

  member function toXML return XMLType is
    childs Ens_XMLType;
    output XMLType;
    begin

        output := XMLType.createxml('<contCountries/>');

        select md.toXML()
        bulk collect into childs
        from table(border) md;

        return addListChildsXml(output,'contCountries',childs);
    end toXML;
end;
/


-------------------------------------------------------------- Country5

drop type T_Country5 force;
/
create or replace  type T_Country5 under T_CountryAbs(
   name          VARCHAR2(60 Byte),
   continent         VARCHAR2(60 Byte),
   contCountries           T_ContCountries,
   CONSTRUCTOR FUNCTION T_Country5(SELF IN OUT NOCOPY T_Country5, codeCountry in VARCHAR2) RETURN SELF AS RESULT,
   overriding member function toXML return XMLType
)
/

create or replace type body T_Country5 as
  CONSTRUCTOR FUNCTION T_Country5(SELF IN OUT NOCOPY T_Country5, codeCountry in VARCHAR2) RETURN SELF AS RESULT IS
  type name_continent IS RECORD(name VARCHAR2(60 Byte),continent VARCHAR2(60 Byte));
  tmp name_continent;
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    select c.name,to_char(e.continent)
    into tmp
    from R_Country c,R_Encompasses e
    where c.code=codeCountry and e.country=c.code 
    and e.percentage=(select max(e2.percentage)
                      from R_Encompasses e2
                      where e2.country=c.code);

    SELF.name:=tmp.name;
    SELF.continent:=tmp.continent;

    if(self.name is NULL or self.continent is NULL) THEN
      raise_application_error( -20001,'les Args de T_Country5 ne respecte pas la DTD name CDATA #REQUIRED continent CDATA #REQUIRED' );
    end if;

    SELF.contCountries:=T_ContCountries(SELF.continent,codeCountry);

    return;
  END T_Country5;

 overriding member function toXML return XMLType is
    childs Ens_XMLType;
    output XMLType;
   begin
    
      select XMLELEMENT("country",XMLATTRIBUTES(name AS "name",continent AS "continent"),contCountries.toXML()) into output from DUAL;

      return output;
   end toXML;
end;
/

-------------------------------------------------------------- Country6

drop type T_Country6 force;
/
create or replace  type T_Country6 under T_CountryAbs(
   name          VARCHAR2(60 Byte),
   blength         NUMBER,
   contCountries           T_ContCountries,
   CONSTRUCTOR FUNCTION T_Country6(SELF IN OUT NOCOPY T_Country6, codeCountry in VARCHAR2) RETURN SELF AS RESULT,
   overriding member function toXML return XMLType
)
/

create or replace type body T_Country6 as
  CONSTRUCTOR FUNCTION T_Country6(SELF IN OUT NOCOPY T_Country6, codeCountry in VARCHAR2) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    select c.name
    into SELF.name
    from R_Country c
    where c.code=codeCountry;

    if(self.name is NULL) THEN
      raise_application_error( -20001,'les Args de T_Country6 ne respecte pas la DTD name CDATA #REQUIRED' );
    end if;

    SELF.contCountries:=T_ContCountries(SELF.blength,codeCountry);

    select sum(c.length)
    into SELF.blength
    from table(SELF.contCountries.border) c;

    if(self.blength is NULL) THEN
      SELF.blength:=0;
    end if;

    return;
  END T_Country6;

 overriding member function toXML return XMLType is
    childs Ens_XMLType;
    output XMLType;
   begin
    
      select XMLELEMENT("country",XMLATTRIBUTES(name AS "name",blength AS "blength"),contCountries.toXML()) into output from DUAL;

      return output;
   end toXML;
end;
/

-------------------------------------------------------------- ex2
drop type T_Ex2 force;
/
create or replace  type T_Ex2 as OBJECT (
   country      Ens_CountryAbs,
   CONSTRUCTOR FUNCTION T_Ex2(SELF IN OUT NOCOPY T_Ex2,country in Ens_CountryAbs) RETURN SELF AS RESULT,
   member function toXML return XMLType
)
/

create or replace type body T_Ex2 as
  CONSTRUCTOR FUNCTION T_Ex2(SELF IN OUT NOCOPY T_Ex2,country in Ens_CountryAbs) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    if(country.count=0) THEN
      raise_application_error( -20001,'T_Ex2 ne respecte pas la DTD country+' );
    end if;

    self.country:=country;

    return;

  END T_Ex2;

  member function toXML return XMLType is
    childs Ens_XMLType;
    output XMLType;
    ens_empty EXCEPTION;
    PRAGMA EXCEPTION_INIT(ens_empty, -20001 );
   begin

      if(country.COUNT=0) then 
        raise_application_error( -20001, 'mondial ne respecte pas la DTD country+' );
      end if;

      output := XMLType.createxml('<mondial/>');

      select c.toXML()
      bulk collect into childs
      from table(country) c;
      
      return addListChildsXml(output,'mondial',childs);
   end;
end;
/


/****************************************************INSTANCES***************************************************************/
-- T_Country3
-- exporter le resultat dans un fichier 
WbExport -type=text
         -file='Country3.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select T_Country3(c.name,T_Geo.factory(c.code))
from Country c;

-- T_Country4
-- exporter le resultat dans un fichier 
WbExport -type=text
         -file='Country4.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select T_Country4(c.name,T_Geo.factory(c.code))
from Country c;


-- T_Country5
-- exporter le resultat dans un fichier 
WbExport -type=text
         -file='Country5.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select T_Country5(c.code).toXML().getClobVal()
from Country c;

-- T_Country6
-- exporter le resultat dans un fichier 
WbExport -type=text
         -file='Country6.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select T_Country6(c.code).toXML().getClobVal()
from Country c;
