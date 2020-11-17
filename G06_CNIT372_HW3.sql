-- Acknowledgement: Codes of the package are from Group 20's HW2 Q2 by Adit Mukherjee for Q2b & Q2e & Q2f (Q2 & Q5 & Q6 here), Brandon Brewer for Q2c & Q2d (Q3 & Q4 here), and Yiqun Zhang for Q2a (Q1 here) along with Q2a-f's auditing and testing (the whole package here).

/*
Yiqun Zhang, Devang Patel, Bradley Orgon, Nathan Gronowski
Group 06
CNIT 37200 - Database Programming
Homework #03 - Packages
*/

-- Question 1-6
-- Package Creation
CREATE OR REPLACE PACKAGE HW03
IS

    FUNCTION km_to_miles (p_kilometers NUMBER)
        RETURN NUMBER;
        
    FUNCTION distance_between_zips (p_zipcode1 VARCHAR2, p_zipcode2 VARCHAR2)
        RETURN NUMBER;
        
    FUNCTION distance_between_zips (p_zipcode1 VARCHAR2)
        RETURN NUMBER;
    
    PROCEDURE poi_within_distance (p_radiusmi IN NUMBER) ;
        
    FUNCTION poi_density (p_radiusmi NUMBER)
        RETURN NUMBER;
        
END HW03;
/
-- Package Body Creation
CREATE OR REPLACE PACKAGE BODY HW03
IS
-- Question 1
    FUNCTION degrees_to_radians (p_degrees NUMBER) 
        RETURN NUMBER 
    AS
        v_pi       NUMBER := 3.1415926;
        v_radian   NUMBER := 0;
        
    BEGIN
    
        v_radian := p_degrees * ( v_pi / 180 );
        RETURN v_radian;
        
    END degrees_to_radians;
    
-- Question 2    
    FUNCTION km_to_miles (p_kilometers NUMBER) 
        RETURN NUMBER 
    AS
        v_kmtomile   NUMBER := 1.609;
        v_miles      NUMBER := 0;
        
    BEGIN
    
        v_miles := p_kilometers / v_kmtomile;
        RETURN v_miles;
        
    END km_to_miles;
        
-- Question 3     
    FUNCTION distance_between_zips (p_zipcode1 VARCHAR2, p_zipcode2 VARCHAR2)
        RETURN NUMBER 
    IS
        v_distance       NUMBER(10, 2) := 0;
        v_zipcode1data   hw2_q1_zipcode%rowtype;
        v_zipcode2data   hw2_q1_zipcode%rowtype;
        r                NUMBER;
        lat1             NUMBER;
        lat2             NUMBER;
        dlat             NUMBER;
        dlon             NUMBER;
        a                NUMBER;
        c                NUMBER;
        
    BEGIN
        SELECT * INTO v_zipcode1data
        FROM hw2_q1_zipcode
        WHERE zipcode = p_zipcode1;
    
        SELECT * INTO v_zipcode2data
        FROM hw2_q1_zipcode
        WHERE zipcode = p_zipcode2; 
    
        r := 6371000;
    
        lat1 := Degrees_To_Radians(v_zipcode1data.latitude);
        lat2 := Degrees_To_Radians(v_zipcode2data.latitude);
           
        dLat := Degrees_To_Radians(v_zipcode1data.latitude - v_zipcode2data.latitude);
        dLon := Degrees_To_Radians(v_zipcode1data.longitude - v_zipcode2data.longitude);
            
        a := power(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * power(sin(dlon / 2), 2);
        c := 2 * atan2(sqrt(a), sqrt(1 - a));
    
        v_distance := ( r * c ) / 1000;
        RETURN v_distance;
        
    EXCEPTION
        WHEN no_data_found THEN
            RETURN -1;
        WHEN OTHERS THEN
            dbms_output.put(sqlcode);
            dbms_output.put(': ');
            dbms_output.put_line(substr(sqlerrm, 1, 1000));
    END distance_between_zips;

-- Question 4        
    FUNCTION distance_between_zips (p_zipcode1 VARCHAR2) 
        RETURN NUMBER 
    IS
        v_distance       NUMBER(10, 2) := 0;
        v_zipcode1data   hw2_q1_zipcode%rowtype;
        v_zipcode2data   hw2_q1_zipcode%rowtype;
        r                NUMBER;
        lat1             NUMBER;
        lat2             NUMBER;
        dlat             NUMBER;
        dlon             NUMBER;
        a                NUMBER;
        c                NUMBER;
    BEGIN
        SELECT * INTO v_zipcode1data
        FROM hw2_q1_zipcode
        WHERE zipcode = p_zipcode1;
    
        SELECT * INTO v_zipcode2data
        FROM hw2_q1_zipcode
        WHERE zipcode = 33605;
    
        r := 6371000;
        lat1 := degrees_to_radians(v_zipcode1data.latitude);
        lat2 := degrees_to_radians(v_zipcode2data.latitude);
        dlat := degrees_to_radians(v_zipcode1data.latitude - v_zipcode2data.latitude);
        dlon := degrees_to_radians(v_zipcode1data.longitude - v_zipcode2data.longitude);
        
        a := power(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * power(sin(dlon / 2), 2);
        c := 2 * atan2(sqrt(a), sqrt(1 - a));
    
        v_distance := ( r * c ) / 1000;
        RETURN v_distance;
        
    EXCEPTION
        WHEN no_data_found THEN
            RETURN -1;
        WHEN OTHERS THEN
            dbms_output.put(sqlcode);
            dbms_output.put(': ');
            dbms_output.put_line(substr(sqlerrm, 1, 1000));
    END distance_between_zips;

-- Question 5   
    PROCEDURE poi_within_distance (p_radiusmi IN NUMBER) 
    AS
        v_radiuskm NUMBER;
        v_distancepoi NUMBER;

        CURSOR c_poi 
        IS 
        (SELECT custlastname || ', ' || custfirstname AS name,'Customer' AS poitype, city, postalcode, nvl(companyname, 'none on record') AS companyname
            FROM customer
            UNION
            SELECT lastname || ', ' || firstname AS name, 'Employee' AS poitype, city, postalcode, 'Eagle Electronics' AS companyname
            FROM employee
            UNION
            SELECT contactname AS name, 'Supplier' AS poitype, city, postalcode, nvl(companyname, 'none on record') AS companyname
            FROM supplier);

        cur_poi c_poi%rowtype; 
    
    BEGIN
        v_radiuskm := p_radiusmi * 1.609;

        v_distancepoi := 0;
        
        OPEN c_poi;
        FETCH c_poi INTO cur_poi;
        
        WHILE c_poi%found LOOP
            SELECT distance_between_zips(cur_poi.postalcode) INTO v_distancepoi
            FROM dual;

            IF v_distancepoi <= v_radiuskm THEN
                dbms_output.put(rpad(cur_poi.name, 20, ' '));
                dbms_output.put(rpad(cur_poi.companyname, 20, ' '));
                dbms_output.put(rpad(cur_poi.poitype, 15, ' '));
                dbms_output.put(rpad(cur_poi.city, 15, ' '));
                dbms_output.put_line(v_distancepoi);
            END IF;

            FETCH c_poi INTO cur_poi;
        END LOOP;

        CLOSE c_poi;
        
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put(sqlcode);
            dbms_output.put(': ');
            dbms_output.put_line(substr(sqlerrm, 1, 1000));
    END poi_within_distance;
    
-- Question 6     
    FUNCTION poi_density (p_radiusmi NUMBER) 
        RETURN NUMBER 
    AS
    
        v_numpoiinr     NUMBER;
        v_radiuskm      NUMBER;
        v_distancepoi   NUMBER;
        
        CURSOR c_poi 
        IS
        (SELECT custlastname || ', ' || custfirstname AS name, 'Customer' AS poitype, city, postalcode, nvl(companyname, 'none on record') AS companyname
        FROM customer
        UNION
        SELECT lastname || ', ' || firstname AS name, 'Employee' AS poitype, city, postalcode, 'Eagle Electronics' AS companyname
        FROM employee
        UNION
        SELECT contactname AS name, 'Supplier' AS poitype, city, postalcode, nvl(companyname, 'none on record') AS companyname
        FROM supplier);

        cur_poi c_poi%rowtype;  
    
    BEGIN
        v_radiuskm := p_radiusmi * 1.609;

        v_distancepoi := 0;
        v_numpoiinr := 0;
        
        OPEN c_poi;
        FETCH c_poi INTO cur_poi;
        
        WHILE c_poi%found LOOP
            SELECT distance_between_zips(cur_poi.postalcode) INTO v_distancepoi
            FROM dual;

            IF v_distancepoi <= v_radiuskm THEN
                v_numpoiinr := v_numpoiinr + 1;
            END IF;
            
            FETCH c_poi INTO cur_poi;
        END LOOP;

        CLOSE c_poi;
        RETURN v_numpoiinr;
        
    EXCEPTION
        WHEN no_data_found THEN
            RETURN -1;
        WHEN OTHERS THEN
            dbms_output.put(sqlcode);
            dbms_output.put(': ');
            dbms_output.put_line(substr(sqlerrm, 1, 1000));
    END poi_density;
        
END HW03;
/

-- Question 7
/*
The functions KM_TO_MILES, DISTANCE_BETWEEN_ZIPS with two parameters, DISTANCE_BETWEEN_ZIPS with only one parameter, POI_WITHIN_DISTANCE, and POI_DENSITY should
be public since they are meant to be used by other people. Those functions are the point of making the package available to the public.
The functions DEGREES_TO_RADIANS should be internal and not available to the public due to it being used in the other functions
and having no use to the public as it's alrealy fixed. If it was altered the rest of the functions would be incorrect so it is better to hide it from the public to ensure accuracy.
*/

-- Question 8
--They would need an EXECUTE privilege to run the functions in the package.
--The syntax is: user1 is package owner, user2 is person to give privilege to:
--grant EXECUTE on user1.packagename to user2
GRANT EXECUTE ON patel691.HW03 TO CNIT372TA;
/
GRANT EXECUTE ON patel691.HW03 TO borgon;
/

-- Question 9
SELECT patel691.HW03.DEGREES_TO_RADIANS(90)
FROM DUAL;
/
SELECT patel691.HW03.KM_TO_MILES(1)
FROM DUAL;
/
SELECT patel691.HW03.DISTANCE_BETWEEN_ZIPS('35005', '33605')
FROM DUAL;
/
SELECT patel691.HW03.DISTANCE_BETWEEN_ZIPS('33605')
FROM DUAL;
/
EXEC patel691.HW03.POI_WITHIN_DISTANCE(10);
/
SELECT patel691.HW03.POI_DENSITY(10)
FROM DUAL;
/

-- Question 10
SELECT patel691.HW03.DEGREES_TO_RADIANS(90)
FROM DUAL;
/
SELECT patel691.HW03.KM_TO_MILES(1)
FROM DUAL;
/
SELECT patel691.HW03.DISTANCE_BETWEEN_ZIPS('35005', '33605')
FROM DUAL;
/
SELECT patel691.HW03.DISTANCE_BETWEEN_ZIPS('33605')
FROM DUAL;
/
EXEC patel691.HW03.POI_WITHIN_DISTANCE(10);
/
SELECT patel691.HW03.POI_DENSITY(10)
FROM DUAL;
/

/* Results:
Question 1-6
Package HW03 compiled


Package Body HW03 compiled

Question 7
The functions KM_TO_MILES, DISTANCE_BETWEEN_ZIPS with two parameters, DISTANCE_BETWEEN_ZIPS with only one parameter, POI_WITHIN_DISTANCE, and POI_DENSITY should
be public since they are meant to be used by other people. Those functions are the point of making the package available to the public.
The functions DEGREES_TO_RADIANS should be internal and not available to the public due to it being used in the other functions
and having no use to the public. If it was altered the rest of the functions would be incorrect so it is better to hide it from the public.

Question 8
They would need an EXECUTE privilege to run the functions in the package.
The syntax is: user1 is package owner, user2 is person to give privilege to: grant EXECUTE on user1.packagename to user2

Grant succeeded.


Grant succeeded.

Question 9
Error starting at line : 272 in command -
SELECT patel691.HW03.DEGREES_TO_RADIANS(90)
FROM DUAL
Error at Command Line : 272 Column : 8
Error report -
SQL Error: ORA-00904: "PATEL691"."HW03"."DEGREES_TO_RADIANS": invalid identifier
00904. 00000 -  "%s: invalid identifier"
*Cause:    
*Action:

Error starting at line : 275 in command -
SELECT patel691.HW03.KM_TO_MILES(1)
FROM DUAL
Error at Command Line : 275 Column : 17
Error report -
SQL Error: ORA-01031: insufficient privileges
01031. 00000 -  "insufficient privileges"
*Cause:    An attempt was made to perform a database operation without
           the necessary privileges.
*Action:   Ask your database administrator or designated security
           administrator to grant you the necessary privileges

Error starting at line : 278 in command -
SELECT patel691.HW03.DISTANCE_BETWEEN_ZIPS('35005', '33605')
FROM DUAL
Error at Command Line : 278 Column : 17
Error report -
SQL Error: ORA-01031: insufficient privileges
01031. 00000 -  "insufficient privileges"
*Cause:    An attempt was made to perform a database operation without
           the necessary privileges.
*Action:   Ask your database administrator or designated security
           administrator to grant you the necessary privileges

Error starting at line : 281 in command -
SELECT patel691.HW03.DISTANCE_BETWEEN_ZIPS('33605')
FROM DUAL
Error at Command Line : 281 Column : 17
Error report -
SQL Error: ORA-01031: insufficient privileges
01031. 00000 -  "insufficient privileges"
*Cause:    An attempt was made to perform a database operation without
           the necessary privileges.
*Action:   Ask your database administrator or designated security
           administrator to grant you the necessary privileges

Error starting at line : 284 in command -
BEGIN patel691.HW03.POI_WITHIN_DISTANCE(10); END;
Error report -
ORA-06550: line 1, column 61:
PLS-00904: insufficient privilege to access object PATEL691.HW03
ORA-06550: line 1, column 52:
PL/SQL: Statement ignored
06550. 00000 -  "line %s, column %s:\n%s"
*Cause:    Usually a PL/SQL compilation error.
*Action:

Error starting at line : 286 in command -
SELECT patel691.HW03.POI_DENSITY(10)
FROM DUAL
Error at Command Line : 286 Column : 17
Error report -
SQL Error: ORA-01031: insufficient privileges
01031. 00000 -  "insufficient privileges"
*Cause:    An attempt was made to perform a database operation without
           the necessary privileges.
*Action:   Ask your database administrator or designated security
           administrator to grant you the necessary privileges

Description of what happens (from a user who is not the owner of the package's schema's view):
If the user who tries to run things in the package is just a regular group member without owner's grants,
meaning the package doesn't reside on his/her side and he/she has no necessary privileges on the target package,
all the things (functions/procedures) in the package simply won't run.
No matter the unauthorized user runs what procedures or functions of the package that are either accessible publicly or privately,
error messages will pop up stating that he/she doesn't have necessary privileges/ insufficient privileges to run the function/procesure he/she wants every try.

Question 10
Error starting at line : 291 in command -
SELECT patel691.HW03.DEGREES_TO_RADIANS(90)
FROM DUAL
Error at Command Line : 291 Column : 8
Error report -
SQL Error: ORA-00904: "PATEL691"."HW03"."DEGREES_TO_RADIANS": invalid identifier
00904. 00000 -  "%s: invalid identifier"
*Cause:    
*Action:

PATEL691.HW03.KM_TO_MILES(1)
----------------------------
                   .62150404


PATEL691.HW03.DISTANCE_BETWEEN_ZIPS('35005','33605')
----------------------------------------------------
                                              759.84


PATEL691.HW03.DISTANCE_BETWEEN_ZIPS('33605')
--------------------------------------------
                                           0


Script output:
PL/SQL procedure successfully completed.
DBMS output: 
Abbott, Michael     Eagle Electronics   Employee       Grand          4.96
Albregts, Nicholas  Eagle Electronics   Employee       Stampton       14.95
Alvarez, Melissa    Eagle Electronics   Employee       Garyville      0
Brose, Jack         Eagle Electronics   Employee       Fort Sutton    3.5
Bush, Rita          Eagle Electronics   Employee       Garyville      0
Cheswick, Sherman   Eagle Electronics   Employee       Palma          6.08
Cochran, Steve      Eagle Electronics   Employee       Stampton       14.95
Day, Ronald         Eagle Electronics   Employee       Stampton       14.95
Deagen, Kathryn     Eagle Electronics   Employee       Garyville      0
Deppe, David        Eagle Electronics   Employee       Garyville      0
Eckelman, Paul      Eagle Electronics   Employee       Fort Sutton    3.5
German, Gary        Eagle Electronics   Employee       Grand          4.96
Gustavel, Kristen   Eagle Electronics   Employee       Garyville      0
Hess, Steve         Eagle Electronics   Employee       Fort Sutton    3.5
Hettinger, Gregory  Eagle Electronics   Employee       Palma          6.08
Hickman, Steven     Eagle Electronics   Employee       Grand          4.96
Jones, Charles      none on record      Customer       Grand          4.96
Jones, Charles      Eagle Electronics   Employee       Grand          4.96
Keck, David         Eagle Electronics   Employee       Garyville      0
Krasner, Jason      Eagle Electronics   Employee       Grand          4.96
Lilley, Edna        Eagle Electronics   Employee       Palma          6.08
Manaugh, Jim        none on record      Customer       Garyville      0
Manaugh, Jim        Eagle Electronics   Employee       Garyville      0
Moore, Kristey      Eagle Electronics   Employee       Fort Sutton    3.5
Moore, Kristy       none on record      Customer       Fort Sutton    3.5
Nairn, Michelle     Eagle Electronics   Employee       Fort Sutton    3.5
Ortman, Austin      Eagle Electronics   Employee       Grand          4.96
Osman, Jamie        Eagle Electronics   Employee       Fort Sutton    3.5
Platt, Joseph       Eagle Electronics   Employee       Stampton       14.95
Reece, Phil         none on record      Customer       Fort Sutton    3.5
Reece, Phil         Eagle Electronics   Employee       Fort Sutton    3.5
Rodgers, Laura      Eagle Electronics   Employee       Stampton       14.95
Roland, Allison     none on record      Customer       Palma          6.08
Roland, Allison     Eagle Electronics   Employee       Palma          6.08
Rosner, Joanne      Eagle Electronics   Employee       Fort Sutton    3.5
Stahley, Ryan       none on record      Customer       Grand          4.96
Stahley, Ryan       Eagle Electronics   Employee       Grand          4.96
Stevenson, GabrielleEagle Electronics   Employee       Stampton       14.95
Tyrie, Meghan       Eagle Electronics   Employee       Garyville      0
Underwood, Patricha Eagle Electronics   Employee       Palma          6.08
Vigus, Todd         Eagle Electronics   Employee       Fort Sutton    3.5
Wendling, Jason     Eagle Electronics   Employee       Grand          4.96
Xolo, Kathleen      Eagle Electronics   Employee       Stampton       14.95
Yates, Tina         Eagle Electronics   Employee       Stampton       14.95
Zobitz, Beth        Eagle Electronics   Employee       Garyville      0
Zollman, Calie      Eagle Electronics   Employee       Stampton       14.95

PATEL691.HW03.POI_DENSITY(10)
-----------------------------
                           46
Description of what happens (from a package schema's owner's view):
If the user who tries to run things in the package is the owner of the schema where the package resides, he/she can run publicly-accessible functions/procedures in that package easily.
When it comes to privately-accessible functions/procedures,
even the owner of the package's schema cannot run those because those are embedded (hidden) within the package body, and don't appear in package header,
so no one can run those, but those can still be seen in the package body by the schema owner.
*/