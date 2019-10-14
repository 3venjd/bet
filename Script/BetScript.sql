alter session set "_ORACLE_SCRIPT"=true;

 SELECT * FROM user_users;

CREATE SMALLFILE TABLESPACE BET_ITM
  DATAFILE 'C:\Users\3velio\Documents\Universidad\AdvancedDataBase\bet\Script\TableSpaces\BetItm.dbf' SIZE 500M,
           'C:\Users\3velio\Documents\Universidad\AdvancedDataBase\bet\Script\TableSpaces\BetItm2.dbf' SIZE 500M;
 
   
  CREATE BIGFILE TABLESPACE BET_AUDITING
  DATAFILE 'C:\Users\3velio\Documents\Universidad\AdvancedDataBase\bet\Script\TableSpaces\BET_AUDITING.dbf'   SIZE 2G;
  
  
  CREATE UNDO TABLESPACE   UNDO_TBS datafile 'C:\Users\3velio\Documents\Universidad\AdvancedDataBase\bet\Script\TableSpaces\UndoTs.db' size 500M;
  
  CREATE PROFILE DEVELOPER LIMIT
		SESSIONS_PER_USER 1
		CONNECT_TIME 60
        IDLE_TIME 30
		FAILED_LOGIN_ATTEMPTS 5
		PASSWORD_LIFE_TIME 90;


CREATE PROFILE WEB_APPLICATION LIMIT
		SESSIONS_PER_USER 5
		CONNECT_TIME UNLIMITED
        IDLE_TIME UNLIMITED
		FAILED_LOGIN_ATTEMPTS 2
		PASSWORD_LIFE_TIME 30;

CREATE PROFILE DBA_ADMIN LIMIT
		SESSIONS_PER_USER 1
		CONNECT_TIME 30
        IDLE_TIME UNLIMITED
		FAILED_LOGIN_ATTEMPTS 2
		PASSWORD_LIFE_TIME 30;

CREATE PROFILE ANALYST LIMIT
		SESSIONS_PER_USER 1
        CONNECT_TIME 30
		IDLE_TIME 5
		FAILED_LOGIN_ATTEMPTS 3
		PASSWORD_LIFE_TIME 30
        PASSWORD_GRACE_TIME 3;

CREATE PROFILE SUPPORT_III LIMIT
		SESSIONS_PER_USER 1
        CONNECT_TIME 240
		IDLE_TIME 5
		FAILED_LOGIN_ATTEMPTS 3
		PASSWORD_LIFE_TIME 20
        PASSWORD_GRACE_TIME 3;
   

CREATE PROFILE REPORTER LIMIT
		SESSIONS_PER_USER 1
		CONNECT_TIME 90
        IDLE_TIME 15
		FAILED_LOGIN_ATTEMPTS 4
		PASSWORD_LIFE_TIME UNLIMITED
        PASSWORD_GRACE_TIME 5;

CREATE PROFILE AUDITOR LIMIT
		SESSIONS_PER_USER 1
		CONNECT_TIME 90
		IDLE_TIME 15
		FAILED_LOGIN_ATTEMPTS 4
		PASSWORD_LIFE_TIME UNLIMITED
        PASSWORD_GRACE_TIME 5;

CREATE USER MAINDEVELOPER IDENTIFIED BY MAINDEVELOPER;

CREATE USER WEB_MAINUSER IDENTIFIED BY WEB_USER;

CREATE USER ADMINDB IDENTIFIED BY ADMINDB;

CREATE USER MAINANALYST IDENTIFIED BY MAINANALYST;

CREATE USER MAININFRAESTRUCTURE IDENTIFIED BY INFRAESTRUCTURESUPP;

CREATE USER REPORTMAKER IDENTIFIED BY REPORTMAKER;

CREATE USER AUDITUSER IDENTIFIED BY AUDITUSER;

CREATE USER WEB_USER2 IDENTIFIED BY WEB_USER2;

CREATE USER DEVELOPERSUPPORT IDENTIFIED BY analyst2;

CREATE USER SUPPORTINFRAESTRUCTURE IDENTIFIED BY auditor2;


ALTER USER MAINDEVELOPER 
PROFILE DEVELOPER; 
GRANT CREATE SESSION TO MAINDEVELOPER;

ALTER USER WEB_MAINUSER 
PROFILE WEB_APPLICATION;
GRANT CREATE SESSION TO WEB_MAINUSER;

ALTER USER ADMINDB 
PROFILE DBA_ADMIN;
GRANT CREATE SESSION TO ADMINDB;

ALTER USER MAINANALYST 
PROFILE ANALYST;
GRANT CREATE SESSION TO MAINANALYST;

ALTER USER MAININFRAESTRUCTURE 
PROFILE SUPPORT_III;
GRANT CREATE SESSION TO MAININFRAESTRUCTURE;


ALTER USER REPORTMAKER 
PROFILE REPORTER;
GRANT CREATE SESSION TO REPORTMAKER;

ALTER USER AUDITUSER 
PROFILE AUDITOR;
GRANT CREATE SESSION TO AUDITUSER;


ALTER USER DEVELOPERSUPPORT 
PROFILE DEVELOPER;
GRANT CREATE SESSION TO DEVELOPERSUPPORT;


ALTER USER WEB_USER2 
PROFILE WEB_APPLICATION;
GRANT CREATE SESSION TO WEB_USER2;


ALTER USER SUPPORTINFRAESTRUCTURE 
PROFILE DEVELOPER;
GRANT CREATE SESSION TO SUPPORTINFRAESTRUCTURE;