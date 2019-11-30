
set serveroutput on;



 --PROCEDIMIENTO 1
/*Crear una funci√≥n que reciba un argumento de tipo n√∫mero,
este representar√° el id de un usuario; la funci√≥n retornar√° TRUE
si el usuario se encuentra logueado en el sistema.
(Usar esta funci√≥n en todos los procedimientos donde
se requiera validar que el usuario tenga una sesi√≥n activa.)*/
CREATE OR REPLACE FUNCTION FNC_USER_LOGUIN(
    ID IN NUMBER )
  RETURN VARCHAR2
AS
  LOGUEADO NUMBER;
BEGIN
  BEGIN
    <<CONSULTA_USUARIO_LOGUEADO>>
    SELECT COUNT(*)
    INTO LOGUEADO
    FROM LOGIN
    WHERE END_HOUR IS NULL
    AND FK_USER     = ID;
  END;
IF LOGUEADO >0 THEN
  RETURN 'TRUE';
END IF;
RETURN 'FALSE';
END FNC_USER_LOGUIN;

--PROCEDIMIENTO 2
/*Crear un procedimiento almacenado que reciba el nombre de la tabla y el id 
del registro que se desea actualizar, la idea de este procedimiento es que
active el soft deletion de dicho registro ubicado en dicha tabla. 
Deber√° tener manejo de excepciones dado el caso que el nombre de la tabla
y/o el id no existan. Nota: Usar (EXECUTE IMMEDIATE)[https://docs.oracle.com/
cd/B19306_01/appdev.102/b14261/dynamic.htm#CHDGJEGD]*/

CREATE OR REPLACE PROCEDURE PCN_PRUEBA 
(
  NOMBRE_TABLA IN VARCHAR2 
, ID_REGISTRO IN NUMBER 
) AS 
BEGIN
 EXECUTE IMMEDIATE 'UPDATE '||NOMBRE_TABLA ||' set active = ''N'' where id = :id' using ID_REGISTRO;
END PCN_PRUEBA;

/*PROCEDIMIENTO 3
Crear un procedimiento que coloque un partido en estado "FINALIZADO", en ese momento deber· calcular las ganancias y pÈrdidas de cada apuesta hecha asociada a ese partido.
*/
CREATE OR REPLACE PROCEDURE END_MATCH IS 

    CURSOR CR_PROFIT IS 
        SELECT 
            BC.NAME_CATEGORY,
            MT.TOTAL_GOAL,
            MT.TOTAL_GOAL_TEAM1,
            MT.TOTAL_GOAL_TEAM2,
            MT.GOAL_TEAM1_HALFTIME,
            MT.GOAL_TEAM2_HALFTIME,
            QM.WINNER_QUOTA,
            QM.QUOTA_1 , 
            QM.QUOTA_2, 
            QM.QUOTA_3, 
            BD.BET_QUOTA,
            BD.BET_VALUE,
            B.TOTAL_PROFIT,
            DU.BALANCE,
            MT.STATUS
        FROM BET B
        INNER JOIN BET_DETAIL BD
        ON BD.FK_BET = B.ID_BET 
        INNER JOIN QUOTA_MATCH QM
        ON QM.ID_QUOTA_MATCH = BD.FK_QUOTA_MATCH
         INNER JOIN BET_CATEGORY BC
        ON BC.ID_BET_CATEGORY = QM.FK_BET_CATEGORY
        INNER JOIN MATCH_ MT
        ON QM.FK_MATCH = MT.ID_MATCH
        INNER JOIN DATAUSER DU
        ON DU.ID_USER = B.FK_DATAUSER
        WHERE MT.STATUS = 'FINALIZADO';

        NAME_CATE BET_CATEGORY.NAME_CATEGORY%TYPE;
        T_GOAL MATCH_.TOTAL_GOAL%TYPE;
        T_GOALT1 MATCH_.TOTAL_GOAL_TEAM1%TYPE;
        T_GOALT2 MATCH_.TOTAL_GOAL_TEAM2%TYPE;
        H_GOALT1 MATCH_.GOAL_TEAM1_HALFTIME%TYPE;
        H_GOALT2 MATCH_.GOAL_TEAM2_HALFTIME%TYPE;        
        W_QTA QUOTA_MATCH.WINNER_QUOTA%TYPE;
        Q1 QUOTA_MATCH.QUOTA_1%TYPE;
        Q2 QUOTA_MATCH.QUOTA_2%TYPE;
        Q3 QUOTA_MATCH.QUOTA_3%TYPE;
        BQ BET_DETAIL.BET_QUOTA%TYPE;
        BV BET_DETAIL.BET_VALUE%TYPE;
        TP BET.TOTAL_PROFIT%TYPE;
        BAL DATAUSER.BALANCE%TYPE;
        S MATCH_.STATUS%TYPE;
BEGIN
    OPEN CR_PROFIT;
       LOOP
         EXIT WHEN CR_PROFIT%NOTFOUND;
            FETCH CR_PROFIT INTO  NAME_CATE,T_GOAL,T_GOALT1,T_GOALT2,H_GOALT1,H_GOALT2,W_QTA,Q1,Q2,Q3,BQ,BV,TP,BAL,S;
            IF S = 'FINALIZADO' THEN
                IF NAME_CATE= 'MAS/MENOS(0,5)' THEN
                    IF T_GOAL = 0 THEN
                        W_QTA := 2;
                    ELSE
                        W_QTA := 3;
                    END IF;
                ELSIF NAME_CATE= 'MAS/MENOS(1,5)' THEN
                    IF T_GOAL <=  1 THEN
                        W_QTA := 2;
                    ELSE
                        W_QTA := 3;
                    END IF;
                ELSIF NAME_CATE= 'MAS/MENOS(2,5)' THEN
                    IF T_GOAL <=  2 THEN
                        W_QTA := 2;
                    ELSE
                        W_QTA := 3;
                    END IF;
                ELSIF NAME_CATE= 'MAS/MENOS(3,5)' THEN
                    IF T_GOAL <=  3 THEN
                        W_QTA := 2;
                    ELSE
                        W_QTA := 3;
                    END IF;
                ELSIF NAME_CATE= 'øAMBOS ANOTARAN GOL?' THEN
                    IF T_GOALT1 >  0 AND T_GOALT2 > 0 THEN
                        W_QTA := 2;
                    ELSE
                        W_QTA := 3;
                    END IF;
                ELSIF NAME_CATE= 'øQUIEN GANA EL 1ER TIEMPO' THEN
                    IF H_GOALT1 > H_GOALT2 THEN
                        W_QTA := 1;
                    ELSIF H_GOALT1 < H_GOALT2 THEN
                        W_QTA := 3;
                    ELSE
                        W_QTA := 2;
                    END IF;
                ELSIF NAME_CATE= 'øQUIEN GANA EL 2DO TIEMPO' THEN
                    IF T_GOALT1 > T_GOALT2 THEN
                        W_QTA := 1;
                    ELSIF T_GOALT1 < T_GOALT2 THEN
                        W_QTA := 3;
                    ELSE
                        W_QTA := 2;
                    END IF;
                ELSIF NAME_CATE= 'øHAY POR LO MENOS UN GOL EN CADA TIEMPO?' THEN
                    IF (T_GOALT1 -H_GOALT1) > 0 OR (T_GOALT2-H_GOALT2) > 0 OR H_GOALT1> 0 OR H_GOALT2 >0   THEN
                        W_QTA := 2;
                    ELSE
                        W_QTA := 3;
                    END IF;
                END IF;
            END IF;
            IF W_QTA = 1 AND BQ = 1 THEN
                TP := BV*Q1;
            ELSIF W_QTA = 2 AND BQ = 2 THEN
                TP := BV*Q2;
            ELSIF W_QTA = 3 AND BQ = 3 THEN
                TP := BV*Q3;
            ELSE
                TP := BV*-1;
            END IF;
            BAL := BAL+TP;
            UPDATE BET SET TOTAL_PROFIT = TP;
            UPDATE DATAUSER SET BALANCE = BAL;
            
        END LOOP;
    CLOSE CR_PROFIT;
END ;

/*
PROCEDIMIENTO 4
Crear un procedimiento que permita procesar el retiro de ganancias, recibir· el monto solicitado y el id del usuario, este procedimiento deber· insertar un registro en la tabla 
movimientos / retiros en estado "PENDIENTE", posteriormente deber· validar si el saldo es suficiente, si el usuario ha proveÌdo toda la documentaciÛn exigida. TambiÈn validar· 
que si tenga una cuenta y un banco v·lido registrado. Si todo se valida sin problemas, deber· colocar el estado "APROBADO" en el registro correspondiente y deber· restar del 
saldo disponible el valor retirado. Si el procedimiento falla alguna validaciÛn, el estado pasar· a "RECHAZADO". El sistema deber· almacenar cu·l es la novedad por la cual se 
rechazÛ (Ya ustedes deciden si crean una nueva tabla, o colocan en la tabla de retiros una columna de observaciones).
*/

CREATE OR REPLACE PROCEDURE WITHDRAWING_PROFITS (AMOUNT FLOAT,ID_USER INT) 
  IS
   CURSOR CR_WP IS 
        SELECT T.STATUS, U.BALANCE, P.APPROVED
        FROM DATAUSER U
        INNER JOIN TRANSACTIONS T
        ON U.ID_USER = T.FK_USER   
        INNER JOIN WITHDRAW W
        ON W.FK_USER = U.ID_USER
        INNER JOIN PROOF P
        ON P.FK_WITHDRAW =W.ID_WITHDRAW
        WHERE U.ID_USER = ID_USER
        ;
        
        T_STATUS TRANSACTIONS.STATUS%TYPE;
        U_BALANCE DATAUSER.BALANCE%TYPE;
        P_APPROVED PROOF.APPROVED%TYPE;
        
  BEGIN
    INSERT INTO TRANSACTIONS 
         (ID_TRANSACTIONS,DESCRIPTIONS,TYPE_TRANSACTIONS,STATUS,TRANSACTION_VALUE,ACTIVE) 
        VALUES(ID_USER,'CHECKING INFORMATION','REVISION','PENDIENTE',AMOUNT,'Y');
    OPEN CR_WP;
    
        FETCH CR_WP INTO  T_STATUS,U_BALANCE,P_APPROVED;
        
        IF U_BALANCE < AMOUNT THEN
            DBMS_OUTPUT.PUT_LINE( 'Saldo no disponible');
            UPDATE TRANSACTIONS SET STATUS = 'REJECTED' WHERE ID_TRANSACTIONS = ID_USER;
        ELSIF P_APPROVED = 'DENIED' THEN
            DBMS_OUTPUT.PUT_LINE( 'No tiene los documentos requeridos');
            UPDATE TRANSACTIONS SET STATUS  = 'REJECTED' WHERE ID_TRANSACTIONS = ID_USER;
        ELSE
            UPDATE TRANSACTIONS SET STATUS = 'APPROVED';
            UPDATE DATAUSER SET BALANCE = BALANCE - AMOUNT WHERE ID_USER = ID_USER;
        END IF;
    CLOSE CR_WP;
  END; 




--PROCEDIMIENTO 5
/*Crear un procedimiento que permita realizar un dep√≥sito,
similar al procedimiento anterior, deber√° validar los posibles
casos para que se apruebe / se rechace esta transacci√≥n. Ejemplo,
validar los montos m√≠nimos y m√°ximos para cada medio de pago.
Si hay alguna novedad guardar el motivo por el cual fue rechazado.
El sistema deber√° validar los l√≠mites de dep√≥sitos para cada usuario.*/
CREATE OR REPLACE PROCEDURE PCN_DEPOSITAR(
    ID_USER       IN NUMBER,
    ID_CLASS      IN NUMBER,
    VALUE_DEPOSIT IN NUMBER )
AS
  ESTADO         VARCHAR2(10):='SUCCESS';
  CONTADOR       NUMBER;
  OBSERVACION    VARCHAR2(200):='SUCCESSFULL';
  ACUM_DIARIO    NUMBER;
  ACUM_SEMANA    NUMBER;
  ACUM_MES       NUMBER;
  LIMITE_DIARIO  NUMBER;
  LIMITE_SEMANA  NUMBER;
  LIMITE_MES     NUMBER;
  ID_TRANSACTION NUMBER;
BEGIN
  --Validar l√¨mite por medio de pago.
  SELECT COUNT(1)
  INTO CONTADOR
  FROM PAYMENT_CLASS
  WHERE ACTIVE       = 'Y'
  AND ID_PAY_CLASS   = ID_CLASS
  AND MINIMUM_VALUE <= VALUE_DEPOSIT;
  IF CONTADOR        = 0 THEN
    ESTADO          := 'REJECTED';
    OBSERVACION     := 'VALOR DEL DEP√?SITO ES MENOR AL M√?NIMO PERMITIDO';
  END IF;
  SELECT COUNT(1)
  INTO CONTADOR
  FROM PAYMENT_CLASS
  WHERE ACTIVE        = 'Y'
  AND ID_PAY_CLASS    = ID_CLASS
  AND MAXIIMUM_VALUE >= VALUE_DEPOSIT;
  IF CONTADOR         = 0 THEN
    ESTADO           := 'REJECTED';
    OBSERVACION      := 'VALOR DEL DEP√?SITO ES MAYOR AL M√?XIMO PERMITIDO';
  END IF;
  BEGIN
    SELECT MAXIMUM_DAILY,
      MAXIMUM_WEEKLY,
      MAXIMUM_MONTHLY
    INTO LIMITE_DIARIO,
      LIMITE_SEMANA,
      LIMITE_MES
    FROM LIMIT_DEPOSIT
    WHERE FK_DATAUSER = ID_USER
    AND ACTIVE        ='Y';
    SELECT SUM(TRANSACTIONS.TRANSACTION_VALUE)
    INTO ACUM_DIARIO
    FROM DEPOSIT
    INNER JOIN TRANSACTIONS
    ON DEPOSIT.FK_TRANSACTION             = TRANSACTIONS.ID_TRANSACTIONS
    WHERE DEPOSIT.FK_USER                 = ID_USER
    AND DEPOSIT.STATUS                    = 'EXITOSO'
    AND DEPOSIT.TRANSACTION_DATE          > TRUNC(SYSDATE); --TRUNC LE QUITA LAS HORA A LAS FECHAS
    IF NVL(ACUM_DIARIO,0) + VALUE_DEPOSIT > LIMITE_DIARIO THEN
      ESTADO                             := 'REJECTED';
      OBSERVACION                        := 'VALOR DEL DEP√?SITO ES MAYOR AL M√?XIMO PERMITIDO DIARIO POR EL USUARIO';
    END IF;
    SELECT SUM(TRANSACTIONS.TRANSACTION_VALUE)
    INTO ACUM_SEMANA
    FROM DEPOSIT
    INNER JOIN TRANSACTIONS
    ON DEPOSIT.FK_TRANSACTION             = TRANSACTIONS.ID_TRANSACTIONS
    WHERE DEPOSIT.FK_USER                 = ID_USER
    AND DEPOSIT.STATUS                    = 'EXITOSO'
    AND DEPOSIT.TRANSACTION_DATE          > TRUNC(sysdate, 'DAY'); --TRUNC LE QUITA LAS HORA A LAS FECHAS
    IF NVL(ACUM_SEMANA,0) + VALUE_DEPOSIT > LIMITE_SEMANA THEN
      ESTADO                             := 'REJECTED';
      OBSERVACION                        := 'VALOR DEL DEP√?SITO ES MAYOR AL M√?XIMO PERMITIDO SEMANAL POR EL USUARIO';
    END IF;
    SELECT SUM(TRANSACTIONS.TRANSACTION_VALUE)
    INTO ACUM_MES
    FROM DEPOSIT
    INNER JOIN TRANSACTIONS
    ON DEPOSIT.FK_TRANSACTION          = TRANSACTIONS.ID_TRANSACTIONS
    WHERE DEPOSIT.FK_USER              = ID_USER
    AND DEPOSIT.STATUS                 = 'EXITOSO'
    AND DEPOSIT.TRANSACTION_DATE       > TRUNC(sysdate, 'MONTH'); --TRUNC LE QUITA LAS HORA A LAS FECHAS
    IF NVL(ACUM_MES,0) + VALUE_DEPOSIT > LIMITE_MES THEN
      ESTADO                          := 'REJECTED';
      OBSERVACION                     := 'VALOR DEL DEP√?SITO ES MAYOR AL M√?XIMO PERMITIDO MENSUAL POR EL USUARIO';
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  END;
  ID_TRANSACTION := SEQ_TRANSACION_ID.nextval;
  INSERT
  INTO TRANSACTIONS
    (
      ID_TRANSACTIONS,
      DESCRIPTIONS,
      TYPE_TRANSACTIONS,
      STATUS,
      TRANSACTION_VALUE,
      ACTIVE,
      FK_USER
    )
    VALUES
    (
      ID_TRANSACTION,
      OBSERVACION,
      'DEPOSITO',
      ESTADO,
      VALUE_DEPOSIT,
      'Y',
      ID_USER
    );
  INSERT
  INTO DEPOSIT
    (
      ID_DEPOSIT,
      TRANSACTION_DATE,
      STATUS,
      ACTIVE,
      FK_USER,
      FK_PAY_CLASS,
      FK_TRANSACTION
    )
    VALUES
    (
      SEQ_DEPOSIT_ID.nextval,
      SYSDATE,
      DECODE( ESTADO,'SUCCESS' ,'EXITOSO', 'RECHAZADA'),
      'Y',
      ID_USER,
      ID_CLASS,
      ID_TRANSACTION
    );
END PCN_DEPOSITAR;  

--PROCEDIMIENTO 6
    /*Crear un procedimiento almacenado que invoque la vista de sesiones activas
    y coloque el campo fin de sesi√≥n con el timestamp actual,
    esto aplicar√° solo para aquellos usuarios que han excedido el
    tiempo en el sistema dependiendo de sus preferencias personales.*/
    CREATE
  OR REPLACE PROCEDURE PCN_CERRAR_SESION AS BEGIN
  UPDATE LOGIN
  SET END_HOUR    = SYSTIMESTAMP
  WHERE ID_LOGIN IN
    (SELECT ID_LOGIN FROM TIEMPO_CONEXION WHERE TIEMPO_FALTANTE <= 0
    );
END PCN_CERRAR_SESION;

--PROCEDIMIENTO 7
/*Crear un procedimiento que reciba el ID de una APUESTA (Las que efectuan los usuarios) y reciba: id_usuario, valor, tipo_apuesta_id, cuota, opciÛn ganadora 
(Ya cada uno mirar· como manejan esta parte conforme al diseÒo que tengan). Con estos par·metros deber· insertar un registro en la tabla detalles de apuesta en estado 
"ABIERTA".*/


CREATE OR REPLACE PROCEDURE CREATE_BET (ID_USER INT,B_VAL FLOAT,BET_CAT INT,B_QUOTA INT,W_OPC INT)  IS

CURSOR CR_BET_CREATE IS 
        SELECT *
        FROM DATAUSER U
        INNER JOIN BET B
        ON B.FK_DATAUSER = U.ID_USER
        INNER JOIN BET_DETAIL BD
        ON BD.FK_USER = U.ID_USER
        INNER JOIN QUOTA_MATCH QM
        ON BD.FK_QUOTA_MATCH = QM.ID_QUOTA_MATCH
        INNER JOIN BET_CATEGORY BC
        ON BC.ID_BET_CATEGORY = QM.FK_BET_CATEGORY
        WHERE U.ID_USER = ID_USER
        ;

BEGIN

     INSERT INTO BET_DETAIL 
         (ID_BET_DETAIL,QOUTA,B_VAL,STATUS,ACTIVE,FK_QU) 
        VALUES(ID_USER,'CHECKING INFORMATION','REVISION','PENDIENTE',AMOUNT,'Y');

END;






