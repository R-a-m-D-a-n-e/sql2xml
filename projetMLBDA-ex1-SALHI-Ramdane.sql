-- Dupliquer les TABLES pour les utiliser dans les TRIGGERs
drop table R_Geo_mountain;
create table R_Geo_mountain as select * from Geo_mountain;

drop table R_Geo_desert;
create table R_Geo_desert as select * from Geo_desert;

drop table R_Geo_island;
create table R_Geo_island as select * from Geo_island;

drop table R_Encompasses;
create table R_Encompasses as select * from Encompasses;

drop table R_Province;
create table R_Province as select * from Province;

drop table R_Airport;
create table R_Airport as select * from Airport;

drop table R_City;
create table R_City as select * from City;

drop table R_IsMember;
create table R_IsMember as select * from IsMember;

drop table R_Language;
create table R_Language as select * from Language;

drop table R_Borders;
create table R_Borders as select * from Borders;

drop table R_Borders;
create table R_Borders as select * from Borders;

/***************************************************************************************************************************/
/***************************************************************************************************************************/
/***********************************************************DTD1************************************************************/
/***************************************************************************************************************************/
/***************************************************************************************************************************/


/*********************************************************Definition********************************************************/

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

-------------------------------------------------------------- Airport 
drop type T_Airport force;
/
create or replace  type T_Airport as OBJECT (
   name         VARCHAR2(60 Byte),
   nearCity    VARCHAR2(60 Byte),
   CONSTRUCTOR FUNCTION T_Airport(SELF IN OUT NOCOPY T_Airport ,name in VARCHAR2,nearCity in VARCHAR2 DEFAULT NULL) RETURN SELF AS RESULT,
   member function toXML return XMLType,
   MAP MEMBER FUNCTION airport_mapping RETURN VARCHAR
)
/

-- Ens_Airport 
drop type Ens_Airport force;
/
CREATE type Ens_Airport as TABLE of T_Airport;
/
-------------------------------------------------------------- Continent 
drop type T_Continent force;
/
create or replace  type T_Continent as OBJECT (
   name         VARCHAR2(60 Byte),
   percent    NUMBER,
   CONSTRUCTOR FUNCTION T_Continent(SELF IN OUT NOCOPY T_Continent ,name in VARCHAR2,percent in NUMBER) RETURN SELF AS RESULT,
   member function toXML return XMLType,
   MAP MEMBER FUNCTION continent_mapping RETURN VARCHAR
)
/

-- Ens_Continent 
drop type Ens_Continent force;
/
CREATE type Ens_Continent as TABLE of T_Continent;
/

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

-------------------------------------------------------------- Island 
drop type T_Island force;
/
create or replace  type T_Island as OBJECT (
   name         VARCHAR2(60 Byte),
   coordinates T_Coordinates,
   CONSTRUCTOR FUNCTION T_Island(SELF IN OUT NOCOPY T_Island ,name in VARCHAR2,coordinates in T_Coordinates default NULL) RETURN SELF AS RESULT,
   member function toXML return XMLType,
   MAP MEMBER FUNCTION island_mapping RETURN VARCHAR
)
/

-- Ens_Island
drop type Ens_Island force;
/
CREATE type Ens_Island as TABLE of ref T_Island;
/

-------------------------------------------------------------- Relief
drop type T_Relief force;
/
create or replace  type T_Relief as OBJECT (
   name         VARCHAR2(60 Byte),
   not INSTANTIABLE member function toXML return XMLType,
   not INSTANTIABLE MAP MEMBER FUNCTION cmp_mapping RETURN VARCHAR
) not FINAL not INSTANTIABLE
/

-- Ens_Relief
drop type Ens_Relief force;
/
CREATE type Ens_Relief as TABLE of ref T_Relief;
/

-------------------------------------------------------------- Desert 
drop type T_Desert force;
/
create or replace  type T_Desert under T_Relief (
   percent    NUMBER,
   CONSTRUCTOR FUNCTION T_Desert(SELF IN OUT NOCOPY T_Desert ,name in VARCHAR2,percent in NUMBER default NULL) RETURN SELF AS RESULT,
   OVERRIDING member function toXML return XMLType,
   OVERRIDING MAP MEMBER FUNCTION cmp_mapping RETURN VARCHAR
)
/

-------------------------------------------------------------- Mountain 
drop type T_Mountain force;
/
create or replace  type T_Mountain under T_Relief (
   height    NUMBER,
   CONSTRUCTOR FUNCTION T_Mountain(SELF IN OUT NOCOPY T_Mountain ,name in VARCHAR2,height in NUMBER) RETURN SELF AS RESULT,
   OVERRIDING member function toXML return XMLType,
   OVERRIDING MAP MEMBER FUNCTION cmp_mapping RETURN VARCHAR
)
/

-------------------------------------------------------------- Province 
drop type T_Province force;
/
create or replace  type T_Province as OBJECT (
   name          VARCHAR2(60 Byte),
   capital       VARCHAR2(60 Byte),
   mountain_desert      Ens_Relief,
   island        Ens_Island,
   CONSTRUCTOR FUNCTION T_Province(SELF IN OUT NOCOPY T_Province ,name in VARCHAR2,capital in VARCHAR2,mountain_desert in Ens_Relief DEFAULT NULL,island in Ens_Island DEFAULT NULL) RETURN SELF AS RESULT,
   member function toXML return XMLType,
   member PROCEDURE addEnsMountainDesertIsland(code in VARCHAR),
   MAP MEMBER FUNCTION province_mapping RETURN VARCHAR 
)
/

-- Ens_Province 
drop type Ens_Province force;
/
CREATE type Ens_Province as TABLE of T_Province;
/

-------------------------------------------------------------- Country 
drop type T_Country force;
/
create or replace  type T_Country as OBJECT (
   name         VARCHAR2(60 Byte),
   idcountry    VARCHAR2(30 Byte),
   continent    Ens_Continent,
   province     Ens_Province,
   airport      Ens_Airport,
   CONSTRUCTOR FUNCTION T_Country(SELF IN OUT NOCOPY T_Country ,idcountry in VARCHAR2,
                                    name in VARCHAR2,continent in Ens_Continent,
                                    province in Ens_Province,airport in Ens_Airport default NULL) RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION T_Country(SELF IN OUT NOCOPY T_Country ,idcountry in VARCHAR2,name in VARCHAR2) RETURN SELF AS RESULT,
   member function toXML return XMLType,
   member PROCEDURE addContinent,
   member PROCEDURE addProvinceAirport
)
/

-- Ens_Country
drop type Ens_Country force;
/
CREATE type Ens_Country as TABLE of ref T_Country;
/

-------------------------------------------------------------- Mondial 
drop type T_Mondial force;
/
create or replace  type T_Mondial as OBJECT (
   country      Ens_Country,
   CONSTRUCTOR FUNCTION T_Mondial(SELF IN OUT NOCOPY T_Mondial,country in Ens_Country) RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION T_Mondial(SELF IN OUT NOCOPY T_Mondial) RETURN SELF AS RESULT,
   member function toXML return XMLType
)
/


/********************************************************TABLE***************************************************************/

-- Table Continent
/* pour moi on a pas besoin de la créer */

-- Table Airport 
/* pour moi on a pas besoin de la créer */


-- Table Island
drop table LesIslands;
create table LesIslands of T_Island (name NOT NULL);

-- Table Relief
drop table LesReliefs;
create table LesReliefs of T_Relief (name NOT NULL);

-- Table Province 
/* pour moi on a pas besoin de la créer */

-- Table Country
drop table LesCountrys;
create table LesCountrys of T_Country(name NOT NULL,idcountry PRIMARY KEY) nested table continent STORE as T1,
                                        nested table province STORE as T2 (nested table mountain_desert STORE as T3, nested table island STORE as T4),
                                        nested table airport STORE as T5;


/*****************************************************METHODES***************************************************************/
-- Airport 
create or replace type body T_Airport as
  CONSTRUCTOR FUNCTION T_Airport(SELF IN OUT NOCOPY T_Airport ,name in VARCHAR2,nearCity in VARCHAR2 DEFAULT NULL) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    self.name:=name;
    if(self.name is null) THEN
      raise_application_error( -20001,'T_Airport ne respecte pas la DTD   name CDATA #REQUIRED' );
    end if;
    self.nearCity:=nearCity;
    return;
  END T_Airport;

 member function toXML return XMLType is
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin
      if(SELF.name is NULL) THEN
        raise_application_error( -20001, name || ' ne respecte pas la DTD name CDATA #REQUIRED' );
      end if;

      if(SELF.nearCity is NULL) THEN
        select XMLELEMENT("airport",XMLATTRIBUTES(name AS "name")) into output from DUAL;
      ELSE
        select XMLELEMENT("airport",XMLATTRIBUTES(name AS "name",nearCity AS "nearCity")) into output from DUAL;
      end if;

      return output;
   end;

  MAP MEMBER FUNCTION airport_mapping RETURN VARCHAR IS
  BEGIN
    return self.name||SELF.nearCity;
  END airport_mapping;
end;
/
-- Continent 
create or replace type body T_Continent as
  CONSTRUCTOR FUNCTION T_Continent(SELF IN OUT NOCOPY T_Continent ,name in VARCHAR2,percent in NUMBER) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    self.name:=name;
    self.percent:=percent;
    if(self.name is null or self.percent is null) THEN
      raise_application_error( -20001,'T_Continent ne respecte pas la DTD   name CDATA #REQUIRED percent CDATA #IMPLIED' );
    end if;

    return;
  END T_Continent;

 member function toXML return XMLType is
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin
      if(self.name is null or self.percent is null) THEN
        raise_application_error( -20001,'T_Continent ne respecte pas la DTD   name CDATA #REQUIRED percent CDATA #IMPLIED' );
      end if;
      select XMLELEMENT("continent",XMLATTRIBUTES(name AS "name",percent AS "percent")) into output from DUAL;
      return output;
   end toXML;

  MAP MEMBER FUNCTION continent_mapping RETURN VARCHAR IS
  BEGIN
    return self.name||SELF.percent;
  END continent_mapping;
end;
/
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
-- Island
create or replace type body T_Island as
  CONSTRUCTOR FUNCTION T_Island(SELF IN OUT NOCOPY T_Island ,name in VARCHAR2,coordinates in T_Coordinates default NULL) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    self.name:=name;

    if(self.name is null) THEN
      raise_application_error( -20001,'T_Island ne respecte pas la DTD   name CDATA #REQUIRED' );
    end if;
    self.coordinates:=coordinates;

    return;
  END T_Island;

  member function toXML return XMLType is
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      if(self.name is null) THEN
        raise_application_error( -20001,'T_Island ne respecte pas la DTD   name CDATA #REQUIRED' );
      end if;

      if(coordinates is not null) then
        select XMLELEMENT("island",XMLATTRIBUTES(name AS "name"),coordinates.toXML()) into output from DUAL;
      ELSE
        select XMLELEMENT("island",XMLATTRIBUTES(name AS "name")) into output from DUAL;
      end if;
      return output;
   end toXML;

  MAP MEMBER FUNCTION island_mapping RETURN VARCHAR IS
  BEGIN
    if (self.coordinates is not null) then
      return self.name||SELF.coordinates.latitude||SELF.coordinates.longitude;
    ELSE
      return self.name;
    end if;
  END island_mapping;
end;
/

-- Desert 
create or replace type body T_Desert as
   CONSTRUCTOR FUNCTION T_Desert(SELF IN OUT NOCOPY T_Desert ,name in VARCHAR2,percent in NUMBER default NULL) RETURN SELF AS RESULT IS
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      self.name:=name;
      if(self.name is null) THEN
        raise_application_error( -20001,'T_Desert ne respecte pas la DTD   name CDATA #REQUIRED' );
      end if;
      self.percent:=percent;

      return;
   END T_Desert;

   OVERRIDING member function toXML return XMLType is
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      if(self.name is null) THEN
        raise_application_error( -20001,'T_Desert ne respecte pas la DTD   name CDATA #REQUIRED' );
      end if;

      if(self.percent is null) THEN
        select XMLELEMENT("desert",XMLATTRIBUTES(name AS "name")) into output from DUAL;
      ELSE
        select XMLELEMENT("desert",XMLATTRIBUTES(name AS "name",percent AS "percent")) into output from DUAL;
      end if;
      return output;
   end toXML;

  OVERRIDING MAP MEMBER FUNCTION cmp_mapping RETURN VARCHAR IS
  BEGIN
    return self.name||SELF.percent;
  END cmp_mapping;
end;
/


-- Mountain 
create or replace type body T_Mountain as
   CONSTRUCTOR FUNCTION T_Mountain(SELF IN OUT NOCOPY T_Mountain ,name in VARCHAR2,height in NUMBER) RETURN SELF AS RESULT IS
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      self.name:=name;
      self.height:=height;
      if(self.name is null or self.height is NULL) THEN
        raise_application_error( -20001,'T_Mountain ne respecte pas la DTD   name CDATA #REQUIRED height CDATA #REQUIRED' );
      end if;

      return;
   END T_Mountain;

  OVERRIDING member function toXML return XMLType is
   output XMLType;
    null_value EXCEPTION;
    PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin
      if(self.name is null or self.height is NULL) THEN
        raise_application_error( -20001, name || ' ne respecte pas la DTD name CDATA #REQUIRED height CDATA #REQUIRED' );
      end if;
      select XMLELEMENT("mountain",XMLATTRIBUTES(name AS "name",height AS "height")) into output from DUAL;  
      return output;
   end toXML;

   
  OVERRIDING MAP MEMBER FUNCTION cmp_mapping RETURN VARCHAR IS
  BEGIN
    return self.name||SELF.height;
  END cmp_mapping;
end;
/


-- Province 
create or replace type body T_Province as
   CONSTRUCTOR FUNCTION T_Province(SELF IN OUT NOCOPY T_Province ,name in VARCHAR2,
                                    capital in VARCHAR2,mountain_desert in Ens_Relief DEFAULT NULL,
                                    island in Ens_Island DEFAULT NULL) RETURN SELF AS RESULT IS
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      self.name:=name;
      self.capital:=capital;
      if(self.name is null or self.capital is NULL) THEN
        raise_application_error( -20001,'T_Province ne respecte pas la DTD   name CDATA #REQUIRED capital CDATA #REQUIRED' );
      end if;
      self.mountain_desert:=mountain_desert;
      self.island:=island;

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

      if(self.mountain_desert is not null) THEN
        select md.toXML()
        bulk collect into childs
        from table(mountain_desert) md;
        output := addListChildsXml(output,'province',childs);
      end if;

      childs.Delete;

      if(self.island is not null) THEN
        select isl.toXML()
        bulk collect into childs
        from table(island) isl;
        output := addListChildsXml(output,'province',childs);
      end if;

      return output;
   end toXML;

   member PROCEDURE addEnsMountainDesertIsland(code in VARCHAR) is
    mountain_desert Ens_Relief;
    island        Ens_Island;
    BEGIN
      select * bulk collect into mountain_desert from( 
      select ref(r) 
      from LesReliefs r,R_Geo_mountain m
      where r.name=m.mountain and m.province=self.name and code=m.country
      union
      select ref(r)
      from LesReliefs r,R_Geo_desert d
      where r.name=d.desert and d.province=self.name and code=d.country
      union
      select VALUE(b)
      from table(self.mountain_desert) b
      );
      
      self.mountain_desert:=mountain_desert;

      select ref(i) 
      bulk collect into island
      from LesIslands i,R_Geo_island g
      where i.name=g.island and g.province=self.name and code=g.country;
      
      self.island:=island;
    END addEnsMountainDesertIsland;

   MAP MEMBER FUNCTION province_mapping RETURN VARCHAR IS
   BEGIN
    return self.name||self.capital;
   END province_mapping;

end;
/


-- Country 
create or replace type body T_Country as
   CONSTRUCTOR FUNCTION T_Country(SELF IN OUT NOCOPY T_Country ,idcountry in VARCHAR2,
                                  name in VARCHAR2,continent in Ens_Continent,
                                  province in Ens_Province,airport in Ens_Airport default NULL)
                                  RETURN SELF AS RESULT IS
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      self.name:=name;
      self.idcountry:=idcountry;
      if(self.name is null or self.idcountry is NULL) THEN
        raise_application_error( -20001,'T_Country ne respecte pas la DTD   name CDATA #REQUIRED idcountry CDATA #REQUIRED' );
      end if;
      if(continent.COUNT=0) then 
        raise_application_error( -20001, name || ' ne respecte pas la DTD continent+' );
      end if;
      self.continent:=continent;

      if(province.COUNT=0) then 
        raise_application_error( -20001, name || ' ne respecte pas la DTD province+' );
      end if;
      self.province:=province;

      self.airport:=airport;

      return;
   END T_Country;

   CONSTRUCTOR FUNCTION T_Country(SELF IN OUT NOCOPY T_Country ,idcountry in VARCHAR2,name in VARCHAR2) RETURN SELF AS RESULT IS
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   BEGIN

      self.name:=name;
      self.idcountry:=idcountry;
      if(self.name is null or self.idcountry is NULL) THEN
        raise_application_error( -20001,'T_Country ne respecte pas la DTD   name CDATA #REQUIRED idcountry CDATA #REQUIRED' );
      end if;

      self.addContinent();
      self.addProvinceAirport();

      return;
   END T_Country;

   member function toXML return XMLType is
    childs Ens_XMLType;
    output XMLType;
    ens_empty EXCEPTION;
    PRAGMA EXCEPTION_INIT(ens_empty, -20001 );
   begin
      select XMLELEMENT("country",XMLATTRIBUTES(name AS "name",idcountry AS "idcountry")) into output from DUAL;

      select c.toXML()
      bulk collect into childs
      from table(continent) c;
      if(childs.COUNT=0) then 
        raise_application_error( -20001, name || ' ne respecte pas la DTD continent+' );
      end if;
      output := addListChildsXml(output,'country',childs);

      childs.Delete;

      select p.toXML()
      bulk collect into childs
      from table(province) p;
      if(childs.COUNT=0) then 
        raise_application_error( -20001, name || ' ne respecte pas la DTD province+' );
      end if;
      output := addListChildsXml(output,'country',childs);

      childs.Delete;

      if(SELF.airport is not NULL) then 
        select a.toXML()
        bulk collect into childs
        from table(airport) a;
        output := addListChildsXml(output,'country',childs);
      end if;
      
      return output;
   end toXML;

  member PROCEDURE addContinent IS
  continent    Ens_Continent;
  ens_empty EXCEPTION;
  PRAGMA EXCEPTION_INIT(ens_empty, -20001 );
  BEGIN
    select * bulk collect into continent from(
      select T_Continent(e.continent,e.percentage) 
      from R_Encompasses e
      where e.country=SELF.idcountry
    );

    SELF.continent:=continent;

    if(SELF.continent.COUNT=0) then 
      raise_application_error( -20001, SELF.name||' '||SELF.idcountry||' ne respecte pas la DTD continent+' );
    end if;

  END addContinent;


  member PROCEDURE addProvinceAirport IS
    province     Ens_Province;
    airport      Ens_Airport;
    ens_empty EXCEPTION;
    PRAGMA EXCEPTION_INIT(ens_empty, -20001 );
   BEGIN
    select * bulk collect into province from(
      select T_Province(p.name, p.capital,Ens_Relief(),Ens_Island())  
      from R_Province p
      where p.Country=SELF.idcountry
    );


    for i in 1..province.COUNT
    LOOP
      province(i).addEnsMountainDesertIsland(SELF.idcountry);
    end LOOP;
    

    SELF.province:=province;

    if(SELF.province.COUNT=0) then 
        raise_application_error( -20001, SELF.name||' '||SELF.idcountry||' ne respecte pas la DTD province+');
    end if;

    select * bulk collect into airport from(
      select T_Airport(a.name, a.city) 
      from R_Airport a
      where a.country=SELF.idcountry
    );

    SELF.airport:=airport;

  END addProvinceAirport;
end;
/

-- Mondial
create or replace type body T_Mondial as
  CONSTRUCTOR FUNCTION T_Mondial(SELF IN OUT NOCOPY T_Mondial,country in Ens_Country) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    SELF.country:=country;
    if(self.country.count=0) THEN
      raise_application_error( -20001,'T_Mondial ne respecte pas la DTD country+' );
    end if;


    return;
  END T_Mondial;

  CONSTRUCTOR FUNCTION T_Mondial(SELF IN OUT NOCOPY T_Mondial) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    select ref(r)
    bulk collect into self.country
    from LesCountrys r;

    if(self.country.count=0) THEN
      raise_application_error( -20001,'T_Mondial ne respecte pas la DTD country+' );
    end if;

    return;
    
  END T_Mondial;

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
----------------------------------- Island
insert into LesIslands
select T_Island(c.name, T_Coordinates(c.Coordinates.latitude,c.Coordinates.longitude)) 
from Island c
where c.Coordinates is not null;

insert into LesIslands
select T_Island(c.name,NULL) 
from Island c
where c.Coordinates is  null;

--Test
select p.toXML().getClobVal()
from LesIslands p;


----------------------------------- Relief
insert into LesReliefs
select T_Desert(c.name, c.area) 
from Desert c;

insert into LesReliefs
select T_Mountain(c.name, c.height) 
from Mountain c;

--Test
select p.toXML().getClobVal()
from LesReliefs p;

select p.toXML().getClobVal()
from LesReliefs p
where value(p) is of type (T_Mountain);

----------------------------------- Country

-- insert into LesCountrys
-- select T_Country(c.name, c.code,Ens_Continent(),Ens_Province(),Ens_Airport()) 
-- from Country c;

insert into LesCountrys
select T_Country(c.code,c.name)
from R_country c, R_Province p ,R_Encompasses e
where c.code=p.country and p.capital is not NULL;


--Test
select p.toXML().getClobVal()
from LesCountrys p;

select *
from R_Province p
where p.Country='GAZA';


----------------------------------- Mondial
-- exporter le resultat dans un fichier 
WbExport -type=text
         -file='Mondial.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select T_Mondial().toXML().getClobVal()
from dual;

/***************************************************************************************************************************/
/***************************************************************************************************************************/
/***********************************************************DTD2************************************************************/
/***************************************************************************************************************************/
/***************************************************************************************************************************/



/*********************************************************Definition********************************************************/


-------------------------------------------------------------- Headquarter 
drop type T_Headquarter force;
/
create or replace  type T_Headquarter as OBJECT (
   name         VARCHAR2(60 Byte),
   CONSTRUCTOR FUNCTION T_Headquarter(SELF IN OUT NOCOPY T_Headquarter, name VARCHAR2) RETURN SELF AS RESULT,
   member function toXML return XMLType,
   MAP MEMBER FUNCTION Headquarter_mapping RETURN VARCHAR
)
/

-- Ens_Headquarter 
drop type Ens_Headquarter force;
/
CREATE type Ens_Headquarter as TABLE of T_Headquarter;
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


-------------------------------------------------------------- Language 
drop type T_Language force;
/
create or replace  type T_Language as OBJECT (
   language         VARCHAR2(60 Byte),
   percent    NUMBER,
   CONSTRUCTOR FUNCTION T_Language(SELF IN OUT NOCOPY T_Language, language in VARCHAR2,percent in NUMBER) RETURN SELF AS RESULT,
   member function toXML return XMLType,
   MAP MEMBER FUNCTION language_mapping RETURN VARCHAR
)
/

-- Ens_Language 
drop type Ens_Language force;
/
CREATE type Ens_Language as TABLE of T_Language;
/


-------------------------------------------------------------- CountryBis 
drop type T_CountryBis force;
/
create or replace  type T_CountryBis as OBJECT (
   code         VARCHAR2(60 Byte),
   name         VARCHAR2(60 Byte),
   population   NUMBER,
   borders      T_Borders,
   language     Ens_Language,
   CONSTRUCTOR FUNCTION T_CountryBis(SELF IN OUT NOCOPY T_CountryBis,code in VARCHAR2, name in VARCHAR2,population in NUMBER) RETURN SELF AS RESULT,
   member function toXML return XMLType,
   STATIC function listLanguages(code in VARCHAR2) return Ens_Language
)
/

-- Ens_CountryBis 
drop type Ens_CountryBis force;
/
CREATE type Ens_CountryBis as TABLE of ref T_CountryBis;
/


-------------------------------------------------------------- Organization 
drop type T_Organization force;
/
create or replace  type T_Organization as OBJECT (
   country      Ens_CountryBis,
   headquarter     T_Headquarter,
   member function toXML return XMLType
)
/

-- Ens_Organization 
drop type Ens_Organization force;
/
CREATE type Ens_Organization as TABLE of ref T_Organization;
/


-------------------------------------------------------------- MondialBis 
drop type T_MondialBis force;
/
create or replace  type T_MondialBis as OBJECT (
   organization      Ens_Organization,
   CONSTRUCTOR FUNCTION T_MondialBis(SELF IN OUT NOCOPY T_MondialBis) RETURN SELF AS RESULT,
   CONSTRUCTOR FUNCTION T_MondialBis(SELF IN OUT NOCOPY T_MondialBis,organization in Ens_Organization) RETURN SELF AS RESULT,
   member function toXML return XMLType
)
/


/********************************************************TABLE***************************************************************/

-- Table CountryBis
drop table LesCountryBiss;
create table LesCountryBiss of T_CountryBis(name NOT NULL,population NOT NULL) nested table language STORE as T6,
                                        nested table borders.border STORE as T7;


-- Table Organization
drop table LesOrganizations;
create table LesOrganizations of T_Organization nested table country STORE as T8;

/*****************************************************METHODES***************************************************************/

-- Headquarter 
create or replace type body T_Headquarter as
  CONSTRUCTOR FUNCTION T_Headquarter(SELF IN OUT NOCOPY T_Headquarter, name VARCHAR2) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    if(name is NULL) THEN
      raise_application_error( -20001,'les Args de T_Headquarter ne respecte pas la DTD name CDATA #REQUIRED' );
    end if;

    SELF.name:=name;

    return;

  END T_Headquarter;

 member function toXML return XMLType is
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin
   
      if(SELF.name is NULL) THEN
        raise_application_error( -20001, name || ' ne respecte pas la DTD name CDATA #REQUIRED' );
      end if;
      
      select XMLELEMENT("headquarter",XMLATTRIBUTES(name AS "name")) into output from DUAL;
      
      return output;
   end;

  MAP MEMBER FUNCTION headquarter_mapping RETURN VARCHAR IS
  BEGIN
    return self.name;
  END headquarter_mapping;
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

   STATIC FUNCTION listBorders(code in VARCHAR) return Ens_Border is
    borders Ens_Border;
    BEGIN

      select * bulk collect into borders from( 
        select T_Border(b.country2,b.length)
        from R_Borders b
        where b.country1=code
        union
        select T_Border(b.country1,b.length)
        from R_Borders b
        where b.country2=code
      );
      
      return borders;

    END listBorders;
end;
/


-- Language 
create or replace type body T_Language as
  CONSTRUCTOR FUNCTION T_Language(SELF IN OUT NOCOPY T_Language, language in VARCHAR2,percent in NUMBER) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    if(language is NULL or percent is NULL) THEN
      raise_application_error( -20001,'les Args de T_Language ne respecte pas la DTD language CDATA #REQUIRED percent CDATA #REQUIRED' );
    end if;

    SELF.language:=language;
    SELF.percent:=percent;

    return;

  END T_Language;

 member function toXML return XMLType is
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin
      if(SELF.language is NULL or SELF.percent is NULL) THEN
        raise_application_error( -20001,'language ne respecte pas la DTD language CDATA #REQUIRED percent CDATA #REQUIRED' );
      end if;
      select XMLELEMENT("language",XMLATTRIBUTES(language AS "language",percent AS "percent")) into output from DUAL;
      return output;
   end;

  MAP MEMBER FUNCTION language_mapping RETURN VARCHAR IS
  BEGIN
    return self.language||self.percent;
  END language_mapping;
end;
/

-- CountryBis 
create or replace type body T_CountryBis as
  CONSTRUCTOR FUNCTION T_CountryBis(SELF IN OUT NOCOPY T_CountryBis,code in VARCHAR2, name in VARCHAR2,population in NUMBER) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    if(name is NULL or population is NULL) THEN
      raise_application_error( -20001,'les Args de T_CountryBis ne respecte pas la DTD name CDATA #REQUIRED population CDATA #REQUIRED' );
    end if;

    SELF.code:=code;
    SELF.name:=name;
    SELF.population:=population;

    return;

  END T_CountryBis;

 member function toXML return XMLType is
   childs Ens_XMLType;
   output XMLType;
   null_value EXCEPTION;
   PRAGMA EXCEPTION_INIT(null_value, -20001 );
   begin
   
      if(SELF.name is NULL or SELF.population is NULL) THEN
        raise_application_error( -20001,'CountryBis ne respecte pas la DTD name CDATA #REQUIRED population CDATA #REQUIRED' );
      end if;

      if(self.code is not null) then
        select XMLELEMENT("country",XMLATTRIBUTES(code AS "code",name AS "name",population AS "population")) into output from DUAL;
      ELSE
        select XMLELEMENT("country",XMLATTRIBUTES(name AS "name",population AS "population")) into output from DUAL;
      end if;

      output := XMLType.appendchildxml(output,'country',borders.toXML());

      select md.toXML()
      bulk collect into childs
      from table(language) md;

      return addListChildsXml(output,'country',childs);
   end toXML;
   
  STATIC function listLanguages(code in VARCHAR2) return Ens_Language IS
  languages Ens_Language;
  BEGIN

    select * bulk collect into languages from( 
      select T_Language(r.name,r.percentage)
      from R_Language r
      where r.country=code
    );
    
    return languages;

  END listLanguages;
end;
/


-- Organization 
create or replace type body T_Organization as
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

      output := XMLType.appendchildxml(output,'organization',headquarter.toXML());

      select md.toXML()
      bulk collect into childs
      from table(country) md;

      return addListChildsXml(output,'organization',childs);
   end toXML;
end;
/


-- MondialBis
create or replace type body T_MondialBis as
  CONSTRUCTOR FUNCTION T_MondialBis(SELF IN OUT NOCOPY T_MondialBis) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    select ref(r)
    bulk collect into self.organization
    from LesOrganizations r;

    if(self.organization.count=0) THEN
      raise_application_error( -20001,'T_MondialBis ne respecte pas la DTD organization+' );
    end if;

    return;

  END T_MondialBis;

  CONSTRUCTOR FUNCTION T_MondialBis(SELF IN OUT NOCOPY T_MondialBis,organization in Ens_Organization) RETURN SELF AS RESULT IS
  null_value EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_value, -20001 );
  BEGIN

    if(organization.count=0) THEN
      raise_application_error( -20001,'T_MondialBis ne respecte pas la DTD organization+' );
    end if;

    self.organization:=organization;

    return;

  END T_MondialBis;

  member function toXML return XMLType is
    childs Ens_XMLType;
    output XMLType;
    ens_empty EXCEPTION;
    PRAGMA EXCEPTION_INIT(ens_empty, -20001 );
   begin

      if(organization.COUNT=0) then 
        raise_application_error( -20001, 'mondial ne respecte pas la DTD organization+' );
      end if;

      output := XMLType.createxml('<mondial/>');

      select c.toXML()
      bulk collect into childs
      from table(organization) c;
      
      return addListChildsXml(output,'mondial',childs);
   end;
end;
/


/*****************************************************TRIGGER***************************************************************/

-- LesCountryBiss
create or replace TRIGGER addBordersLanguages BEFORE
  INSERT ON LesCountryBiss
  FOR EACH ROW
  BEGIN

    :new.borders:=T_Borders(T_Borders.listBorders(:new.code));

    :new.language:=T_CountryBis.listLanguages(:new.code);

  END addBordersLanguages;
/


-- LesOrganizations
create or replace TRIGGER addCountrys BEFORE
  INSERT ON LesOrganizations
  FOR EACH ROW
  DECLARE
  country    Ens_CountryBis;
  ens_empty EXCEPTION;
  PRAGMA EXCEPTION_INIT(ens_empty, -20001 );
  BEGIN

    select * bulk collect into country from( 
      select ref(c)
      from LesCountryBiss c,R_IsMember m
      where m.country=c.code and :new.headquarter.name=m.organization
      union
      select VALUE(b)
      from table(:new.country) b
    );

    if(country.count=0) THEN
      raise_application_error( -20001,'Organization ne respecte pas la DTD country+' );
    end if;
    
    :new.country:=country;

  END addCountrys;
/

/****************************************************INSTANCES***************************************************************/


-- LesCountryBiss
insert into LesCountryBiss
select T_CountryBis(c.code,c.name,c.population)
from Country c;

-- Test
select c.toXML().getClobVal()
from LesCountryBiss c;


-- LesCountryBiss
insert into LesOrganizations
select T_Organization(Ens_CountryBis(),T_Headquarter(o.abbreviation))
from Organization o;

-- Test
select o.toXML().getClobVal()
from LesOrganizations o;


----------------------------------- MondialBis
-- exporter le resultat dans un fichier 
WbExport -type=text
         -file='MondialBis.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select T_MondialBis().toXML().getClobVal()
from dual;

