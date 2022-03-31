-- drop table R_River;
-- create table R_River as select * from River;



-- Ens_XMLType
drop type Ens_XMLType force;
/
CREATE type Ens_XMLType as TABLE of XMLType;
/

create or replace function addListChildsXml(root in XMLType,name_root in varchar,childs in Ens_XMLType) return XMLType is
  output XMLType;
  begin
      output := root;
      for i IN 1..childs.COUNT
      loop
         output := XMLType.appendchildxml(output,name_root, childs(i));   
      end loop;
      return output;
  end addListChildsXml;
/

/*********************************************************Definition********************************************************/

-------------------------------------------------------------- Coordinates 
drop type T_Coordinates force;
/
create or replace  type T_Coordinates as OBJECT (
   latitude         NUMBER,
   longitude    NUMBER,
  CONSTRUCTOR FUNCTION T_Coordinates(SELF IN OUT NOCOPY T_Coordinates ,latitude in NUMBER,longitude in NUMBER) RETURN SELF AS RESULT,
   member function toXML return XMLType
)
/

-------------------------------------------------------------- River 
drop type T_River force;
/
create or replace  type T_River as OBJECT (
   name         VARCHAR2(60 Byte),
   coordinates T_Coordinates,
   CONSTRUCTOR FUNCTION T_River(SELF IN OUT NOCOPY T_River ,name in VARCHAR2,coordinates in T_Coordinates) RETURN SELF AS RESULT,
   member function toXML return XMLType,
   MAP MEMBER FUNCTION river_mapping RETURN VARCHAR
)
/

-- Ens_River
drop type Ens_River force;
/
CREATE type Ens_River as TABLE of ref T_River;
/

-------------------------------------------------------------- Mountain 
drop type T_Mountain force;
/
create or replace  type T_Mountain as OBJECT (
   name         VARCHAR2(60 Byte),
   height    NUMBER,
   coordinates T_Coordinates,
   CONSTRUCTOR FUNCTION T_Mountain(SELF IN OUT NOCOPY T_Mountain ,name in VARCHAR2,height in NUMBER,coordinates in T_Coordinates) RETURN SELF AS RESULT,
   OVERRIDING member function toXML return XMLType,
   OVERRIDING MAP MEMBER FUNCTION cmp_mapping RETURN VARCHAR
)
/

-- Ens_Mountain
drop type Ens_Mountain force;
/
CREATE type Ens_Mountain as TABLE of ref T_Mountain;
/

-------------------------------------------------------------- Province 
drop type T_Province force;
/
create or replace  type T_Province as OBJECT (
   name          VARCHAR2(60 Byte),
   capital       VARCHAR2(60 Byte),
   mountain     Ens_Mountain,
   river        Ens_River,
   CONSTRUCTOR FUNCTION T_Province(SELF IN OUT NOCOPY T_Province ,name in VARCHAR2,
                                  capital in VARCHAR2,mountain in Ens_Mountain DEFAULT NULL,
                                  river in Ens_River DEFAULT NULL) RETURN SELF AS RESULT,
   member function toXML return XMLType,
   MAP MEMBER FUNCTION province_mapping RETURN VARCHAR 
)
/

-- Ens_Province 
drop type Ens_Province force;
/
CREATE type Ens_Province as TABLE of T_Province;
/

-------------------------------------------------------------- Border 
drop type T_Border force;
/
create or replace  type T_Border as OBJECT (
   countryCode         VARCHAR2(60 Byte),
   length    NUMBER,
  CONSTRUCTOR FUNCTION T_Border(SELF IN OUT NOCOPY T_Border, countryCode in VARCHAR2,length in NUMBER) 
    RETURN SELF AS RESULT,
   member function toXML return XMLType,
   MAP MEMBER FUNCTION border_mapping RETURN VARCHAR
)
/

-- Ens_Border 
drop type Ens_Border force;
/
CREATE type Ens_Border as TABLE of T_Border;
/

-------------------------------------------------------------- Borders 
drop type T_Borders force;
/
create or replace  type T_Borders as OBJECT (
   border         Ens_Border,
   member function toXML return XMLType,
   STATIC FUNCTION listBorders(code in VARCHAR) return Ens_Border
)
/

-------------------------------------------------------------- Country 
drop type T_Country force;
/
create or replace  type T_Country as OBJECT (
   idcountry    VARCHAR2(30 Byte),
   name         VARCHAR2(60 Byte),
   population   NUMBER,
   province     Ens_Province,
   borders      T_Borders,
   CONSTRUCTOR FUNCTION T_Country(SELF IN OUT NOCOPY T_Country ,idcountry in VARCHAR2,
                                    name in VARCHAR2,population in NUMBER,
                                    province in Ens_Province,borders in T_Borders default NULL)
                                    RETURN SELF AS RESULT,
   member function toXML return XMLType,
)
/


-- Ens_Country
drop type Ens_Country force;
/
CREATE type Ens_Country as TABLE of ref T_Country;
/

-------------------------------------------------------------- Organization 
drop type T_Organization force;
/
create or replace  type T_Organization as OBJECT (
   name      VARCHAR2,
   country      Ens_Country,
   CONSTRUCTOR FUNCTION T_Organization(SELF IN OUT NOCOPY T_Organization,name in VARCHAR2, country in Ens_Country) RETURN SELF AS RESULT,
   member function toXML return XMLType
)
/

-- Ens_Organization 
drop type Ens_Organization force;
/
CREATE type Ens_Organization as TABLE of ref T_Organization;
/

/********************************************************TABLE***************************************************************/

-- Table River
drop table LesRivers;
create table LesRivers of T_River (name NOT NULL,coordinates NOT NULL);

-- Table Mountain
drop table LesMountains;
create table LesMountains of T_Mountain (name NOT NULL,height NOT NULL,coordinates NOT NULL);

-- Table Country
drop table LesCountrys;
create table LesCountrys of T_Country(population NOT NULL,name NOT NULL,idcountry PRIMARY KEY) nested table borders.border STORE as T11,
                                        nested table province STORE as T12 (nested table mountain STORE as T13, nested table river STORE as T14);

-- Table Organization
drop table LesOrganizations;
create table LesOrganizations of T_Organization nested table country STORE as T18;




/*****************************************************METHODES***************************************************************/

-- Coordinates 
create or replace type body T_Coordinates as
  CONSTRUCTOR FUNCTION T_Coordinates(SELF IN OUT NOCOPY T_Coordinates ,latitude in NUMBER,longitude in NUMBER) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    self.latitude:=latitude;
    self.longitude:=longitude;
    if(self.latitude is null or self.longitude is null) THEN
      raise_application_error( -20001,'T_Coordinates ne respecte pas la DTD   latitude CDATA #REQUIRED longitude CDATA #IMPLIED' );
    end if;

    return;
  END T_Coordinates;

 member function toXML return XMLType is
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin
      if(self.latitude is null or self.longitude is null) THEN
        raise_application_error( -20001,'T_Continent ne respecte pas la DTD   latitude CDATA #REQUIRED longitude CDATA #IMPLIED' );
      end if;
      select XMLELEMENT("coordinates",XMLATTRIBUTES(latitude AS "latitude",longitude AS "longitude")) into output from DUAL;
      return output;
   end;
end;
/
-- River
create or replace type body T_River as
  CONSTRUCTOR FUNCTION T_River(SELF IN OUT NOCOPY T_River ,name in VARCHAR2,coordinates in T_Coordinates) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    self.name:=name;
    self.coordinates:=coordinates;

    if(self.name is null or self.coordinates is null) THEN
      raise_application_error( -20001,'T_River ne respecte pas la DTD coordinates  name CDATA #REQUIRED' );
    end if;

    return;
  END T_River;

  member function toXML return XMLType is
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      if(self.name is null or self.coordinates is null) THEN
        raise_application_error( -20001,'T_River ne respecte pas la DTD   name CDATA #REQUIRED' );
      end if;

      select XMLELEMENT("river",XMLATTRIBUTES(name AS "name"),coordinates.toXML()) into output from DUAL;

      return output;
   end toXML;

  MAP MEMBER FUNCTION river_mapping RETURN VARCHAR IS
  BEGIN
    if (self.coordinates is not null) then
      return self.name||SELF.coordinates.latitude||SELF.coordinates.longitude;
    ELSE
      return self.name;
    end if;
  END river_mapping;
end;
/

-- Mountain 
create or replace type body T_Mountain as
   CONSTRUCTOR FUNCTION T_Mountain(SELF IN OUT NOCOPY T_Mountain ,name in VARCHAR2,height in NUMBER,coordinates in T_Coordinates) RETURN SELF AS RESULT IS
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      self.name:=name;
      self.height:=height;
      self.coordinates:=coordinates;
      if(self.name is null or self.height is NULL or self.coordinates is NULL) THEN
        raise_application_error( -20001,'T_Mountain ne respecte pas la DTD   name CDATA #REQUIRED height CDATA #REQUIRED' );
      end if;

      return;
   END T_Mountain;

  OVERRIDING member function toXML return XMLType is
   output XMLType;
    null_value EXCEPTION;
    PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin
      if(self.name is null or self.height is NULL or self.coordinates is NULL) THEN
        raise_application_error( -20001, name || ' ne respecte pas la DTD name CDATA #REQUIRED height CDATA #REQUIRED' );
      end if;
      select XMLELEMENT("mountain",XMLATTRIBUTES(name AS "name",height AS "height"),self.coordinates.toXML()) into output from DUAL;  
      return output;
   end toXML;

   
  OVERRIDING MAP MEMBER FUNCTION cmp_mapping RETURN VARCHAR IS
  BEGIN
    return self.name||SELF.height||SELF.coordinates.latitude||SELF.coordinates.longitude;
  END cmp_mapping;
end;
/


-- Province 
create or replace type body T_Province as
      CONSTRUCTOR FUNCTION T_Province(SELF IN OUT NOCOPY T_Province ,name in VARCHAR2,
                                  capital in VARCHAR2,mountain in Ens_Mountain DEFAULT NULL,
                                  river in Ens_River DEFAULT NULL) RETURN SELF AS RESULT IS
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      self.name:=name;
      self.capital:=capital;
      if(self.name is null or self.capital is NULL) THEN
        raise_application_error( -20001,'T_Province ne respecte pas la DTD   name CDATA #REQUIRED capital CDATA #REQUIRED' );
      end if;
      self.mountain:=mountain;
      self.river:=river;

      return;
   END T_Province;

   member function toXML return XMLType is
   childs Ens_XMLType;
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      if(self.name is null or self.capital is NULL) THEN
        raise_application_error( -20001,'T_Province ne respecte pas la DTD   name CDATA #REQUIRED capital CDATA #REQUIRED' );
      end if;

      select XMLELEMENT("province",XMLATTRIBUTES(name AS "name",capital AS "capital")) into output from DUAL;

      if(self.mountain is not null) THEN
        select md.toXML()
        bulk collect into childs
        from table(mountain) md;
        output := addListChildsXml(output,'province',childs);
      end if;

      childs.Delete;

      if(self.river is not null) THEN
        select isl.toXML()
        bulk collect into childs
        from table(river) isl;
        output := addListChildsXml(output,'province',childs);
      end if;

      return output;
   end toXML;
end;
/


-- Border 
create or replace type body T_Border as
  CONSTRUCTOR FUNCTION T_Border(SELF IN OUT NOCOPY T_Border, countryCode in VARCHAR2,length in NUMBER) RETURN SELF AS RESULT is
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    if(countryCode is NULL or length is NULL) THEN
      raise_application_error( -20001,'les Args de T_Border ne respecte pas la DTD countryCode CDATA #REQUIRED length CDATA #REQUIRED' );
    end if;

    SELF.countryCode:=countryCode;
    SELF.length:=length;

    return;

  END T_Border;

 member function toXML return XMLType is
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin

      if(SELF.countryCode is NULL or SELF.length is NULL) THEN
        raise_application_error( -20001,'border ne respecte pas la DTD length CDATA #REQUIRED countryCode CDATA #REQUIRED' );
      end if;

      select XMLELEMENT("border",XMLATTRIBUTES(countryCode AS "countryCode",length AS "length")) into output from DUAL;
      
      return output;
   end;

  MAP MEMBER FUNCTION border_mapping RETURN VARCHAR IS
  BEGIN
    return self.countryCode||self.length;
  END border_mapping;
end;
/

-- Borders 
create or replace type body T_Borders as
 member function toXML return XMLType is
   childs Ens_XMLType;
   output XMLType;
   begin

      output := XMLType.createxml('<borders/>');

      select md.toXML()
      bulk collect into childs
      from table(border) md;

      return addListChildsXml(output,'borders',childs);
   end toXML;
end;
/



-- Country 
create or replace type body T_Country as
   CONSTRUCTOR FUNCTION T_Country(SELF IN OUT NOCOPY T_Country ,idcountry in VARCHAR2,
                                    name in VARCHAR2,population in NUMBER,
                                    province in Ens_Province,borders in T_Borders default NULL)
                                    RETURN SELF AS RESULT,
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      self.name:=name;
      self.idcountry:=idcountry;
      if(self.name is null or self.idcountry is NULL) THEN
        raise_application_error( -20001,'T_Country ne respecte pas la DTD   name CDATA #REQUIRED idcountry CDATA #REQUIRED' );
      end if;

      if(province.COUNT=0) then 
        raise_application_error( -20001, name || ' ne respecte pas la DTD province+' );
      end if;
      self.province:=province;

      if(borders is null) then 
        raise_application_error( -20001, name || ' ne respecte pas la DTD borders' );
      end if;
      self.borders:=borders;

      return;
   END T_Country;

   member function toXML return XMLType is
    childs Ens_XMLType;
    output XMLType;
    ens_empty EXCEPTION;
    PRAGMA EXCEPTION_INIT(ens_empty, -20001 );
   begin

      if(self.name is null or self.idcountry is NULL) THEN
        raise_application_error( -20001,'T_Country ne respecte pas la DTD   name CDATA #REQUIRED idcountry CDATA #REQUIRED' );
      end if;
      select XMLELEMENT("country",XMLATTRIBUTES(name AS "name",idcountry AS "idcountry")) into output from DUAL;

      select p.toXML()
      bulk collect into childs
      from table(province) p;
      if(childs.COUNT=0) then 
        raise_application_error( -20001, name || ' ne respecte pas la DTD province+' );
      end if;
      output := addListChildsXml(output,'country',childs);

      if(borders is null) then 
        raise_application_error( -20001, name || ' ne respecte pas la DTD borders' );
      end if;
      output := XMLType.appendchildxml(output,'country', borders.toXML()); 
      
      return output;
   end toXML;
end;
/



-- Organization 
create or replace type body T_Organization as
  CONSTRUCTOR FUNCTION T_Organization(SELF IN OUT NOCOPY T_Organization,name in VARCHAR2, country in Ens_Country) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    if(country.count=0 or name is null) THEN
      raise_application_error( -20001,'les Args de T_Organization ne respecte pas la DTD country+ name CDATA #REQUIRED ' );
    end if;

    SELF.country:=country;
    return;
  END T_Organization;

  member function toXML return XMLType is
   childs Ens_XMLType;
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin
   
      if(SELF.country.count=0) THEN
        raise_application_error( -20001,'Organization ne respecte pas la DTD country+' );
      end if;

      output := XMLType.createxml('<organization/>');

      select md.toXML()
      bulk collect into childs
      from table(country) md;

      return addListChildsXml(output,'organization',childs);
   end toXML;
end;
/
