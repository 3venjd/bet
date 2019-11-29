-- VISTA 1
  /*Sumar el valor ganado de todas las apuestas de los usuarios que est�n en
  estado ganado de aquellos partidos asociados a las apuestas que se efectuaron 
  en el trancurso de la semana y mostrarlas ordenadas por el valor m�s alto; 
  El nombre de la vista ser� "GANADORES_SEMANALES" y tendr� dos columnas:
  nombre completo y valor acumulado.*/
  
  CREATE VIEW GANADORES_SEMANALES AS
  SELECT DOCUMENTOUSUARIO.FIRSTNAME
    ||' '
    ||DOCUMENTOUSUARIO.LASTNAME AS NOMBRE,
    SUM(APUESTA.TOTAL_PROFIT)   AS VALOR_ACUMULADO
  FROM MATCH_ PARTIDO
  INNER JOIN QUOTA_MATCH CUOTAPARTIDO
  ON CUOTAPARTIDO.FK_MATCH = PARTIDO.ID_MATCH
  INNER JOIN BET_DETAIL DETALLEAPUESTA
  ON DETALLEAPUESTA.FK_QUOTA_MATCH = CUOTAPARTIDO.ID_QUOTA_MATCH
  INNER JOIN BET APUESTA
  ON APUESTA.ID_BET = DETALLEAPUESTA.FK_BET
  INNER JOIN DATAUSER DATOSUSUARIOS
  ON DATOSUSUARIOS.ID_USER = APUESTA.FK_DATAUSER
  INNER JOIN DOCUMENT_USER DOCUMENTOUSUARIO
  ON DOCUMENTOUSUARIO.ID_DOCUMENT = DATOSUSUARIOS.FK_DOCUMENT
  WHERE PARTIDO.MATCH_DATE BETWEEN TRUNC(sysdate, 'DAY') AND TRUNC(sysdate, 'DAY')+6
  AND APUESTA.STATUS ='GANADA'
  GROUP BY DOCUMENTOUSUARIO.FIRSTNAME
    ||' '
    ||DOCUMENTOUSUARIO.LASTNAME
  ORDER BY VALOR_ACUMULADO DESC;
  SELECT TRUNC(sysdate, 'MONTH') start_of_the_week,
    TRUNC(sysdate, 'DAY')+6 end_of_the_week
  FROM dual;
  SELECT * FROM DATAUSER;
  SELECT * FROM DOCUMENT_USER;
  
  --VISTA 3 
  /*Nombre de la vista: RESUMEN_APUESTAS. Esta vista mostrar� el resumen de cada
  apuesta efectuada en el sistema, la informaci�n de la siguiente imagen
  corresponder� a cada columna (Omitir la siguiente columna Pago m�x. incl.
  5% bono (293.517,58 $)). La idea es que cuando se llame la vista, muestre
  la informaci�n �nicamente de esa apuesta en particular:
  COLUMNAS:  N�MERO DE APUESTAS,  VALOR TOTAL DE APUESTAS  M�XIMO TOTAL CUOTA
  VALOR PAGADO.*/
  
  CREATE VIEW RESUMEN_APUESTAS  AS
  SELECT FK_BET                 AS ID,
    COUNT(1)                    AS NUMERO_APUESTAS,
    SUM (BET_VALUE)             AS VALOR_TOTAL_APUESTAS,
    MAX (BET_QUOTA)             AS MAXIMO_TOTAL_CUOTA,
    SUM (APUESTAS.TOTAL_PROFIT) AS VALOR_PAGADO
  FROM BET_DETAIL DETALLE_APUESTA
  INNER JOIN BET APUESTAS
  ON DETALLE_APUESTA.FK_BET = APUESTAS.ID_BET
  GROUP BY FK_BET;
  
  --VISTA 4
  /*Para la siguiente vista deber�n alterar el manejo de sesiones de usuario,
  el sistema deber� guardar el timestamp de la hora de sesi�n y el
  timestamp del fin de sesi�n, si el usuario tiene el campo fin de
  sesi�n en null, significa que la sesi�n est� activa. Crear una
  vista que traiga las personas que tienen una sesi�n activa,
  ordenado por la hora de inicio de sesi�n, mostrando las personas
  que m�s tiempo llevan activas; adicional, deber� tener una columna
  que calcule cu�ntas horas lleva en el sistema con respecto a la hora actual,
  la siguiente columna ser� la cantidad de horas seleccionada en las
  preferencias de usuario, finalmente, habr� una columna que reste
  cu�nto tiempo le falta para que se cierre la sesi�n.
  (si aparece un valor negativo, significa que el usuario excedi� el tiempo en el sistema)*/
  
  CREATE VIEW TIEMPO_CONEXION AS
  SELECT LOGIN.ID_LOGIN,
    DOCUMENTOUSUARIO.FIRSTNAME
    ||' '
    ||DOCUMENTOUSUARIO.LASTNAME AS NOMBRE,
    extract( DAY FROM (SYSTIMESTAMP - LOGIN.INITIAL_HOUR ) )*24                               --*60
                                    +extract( HOUR FROM (SYSTIMESTAMP - LOGIN.INITIAL_HOUR ) )--*60 +
    --extract( MINUTE from (SYSTIMESTAMP - LOGIN.INITIAL_HOUR ) )
    AS TIEMPO_CONEXION,
    CLOSE_SESSION - (extract( DAY FROM (SYSTIMESTAMP - LOGIN.INITIAL_HOUR ) )*24 --*60
                  +extract( HOUR FROM (SYSTIMESTAMP - LOGIN.INITIAL_HOUR ) ))    --*60 +
    --extract( MINUTE from (SYSTIMESTAMP - LOGIN.INITIAL_HOUR ) )
    AS TIEMPO_FALTANTE
  FROM LOGIN
  INNER JOIN DATAUSER DATOSUSUARIO
  ON LOGIN.FK_USER = DATOSUSUARIO.ID_USER
  INNER JOIN DOCUMENT_USER DOCUMENTOUSUARIO
  ON DOCUMENTOUSUARIO.ID_DOCUMENT = DATOSUSUARIO.FK_DOCUMENT
  WHERE END_HOUR                 IS NULL
  ORDER BY INITIAL_HOUR ASC