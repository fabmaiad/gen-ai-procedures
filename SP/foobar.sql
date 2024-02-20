CREATE OR REPLACE PROCEDURE READ_FILE_TO_TEMP(file_name IN NVARCHAR2, dir IN NVARCHAR2) 
AS
    TYPE LIST_OF_TEMP  IS TABLE OF temp_file%ROWTYPE;
    TYPE LSIT_STRING   IS TABLE OF NVARCHAR2(2000);

    v_temps   LIST_OF_TEMP         DEFAULT LIST_OF_TEMP();
    v_count   NUMBER               DEFAULT v_temps.COUNT;
    v_file    UTL_FILE.FILE_TYPE;
    v_line    NVARCHAR2(1000);

    v_rows    LSIT_STRING;

    FUNCTION TEST_SPLIT (TEXT IN NVARCHAR2) 
    RETURN LSIT_STRING
    IS
        V_TEXTS   LSIT_STRING;
    BEGIN
         SELECT 
            REGEXP_SUBSTR(TEXT,'[^,]+', 1, LEVEL) 
            BULK COLLECT  INTO V_TEXTS  
        FROM DUAL CONNECT BY REGEXP_SUBSTR(TEXT, '[^,]+', 1, LEVEL) IS NOT NULL;
        RETURN V_TEXTS;
    END;

BEGIN
    v_file := UTL_FILE.FOPEN(dir, file_name,'R', 1000);
    LOOP
        BEGIN

            UTL_FILE.GET_LINE(v_file, v_line);
            v_rows := TEST_SPLIT(v_line);

            v_temps.EXTEND(1);
            v_count := v_temps.COUNT;

            v_temps(v_count).ID          := C##ORGANIZATION.seq_temp_file.NEXTVAL;
            v_temps(v_count).FIRST_NAME  := v_rows(1);
            v_temps(v_count).LAST_NAME   := v_rows(2);
            v_temps(v_count).CREATE_DATE := CURRENT_TIMESTAMP;

            INSERT INTO temp_file VALUES v_temps(v_count);
            COMMIT;

            EXCEPTION  
            WHEN NO_DATA_FOUND THEN 
                UTL_FILE.FCLOSE(v_file);
                EXIT;
        END;
    END LOOP;
    UTL_FILE.FCLOSE(v_file);
    DBMS_OUTPUT.PUT_LINE ('Finish.');
END READ_FILE_TO_TEMP;