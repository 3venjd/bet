-- VISTA 1
  /*Sumar el valor ganado de todas las apuestas de los usuarios que están en
  estado ganado de aquellos partidos asociados a las apuestas que se efectuaron 
  en el trancurso de la semana y mostrarlas ordenadas por el valor más alto; 
  El nombre de la vista será "GANADORES_SEMANALES" y tendrá dos columnas:
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
  /*Nombre de la vista: RESUMEN_APUESTAS. Esta vista mostrará el resumen de cada
  apuesta efectuada en el sistema, la información de la siguiente imagen
  corresponderá a cada columna (Omitir la siguiente columna Pago máx. incl.
  5% bono (293.517,58 $)). La idea es que cuando se llame la vista, muestre
  la información únicamente de esa apuesta en particular:
  COLUMNAS:  NÙMERO DE APUESTAS,  VALOR TOTAL DE APUESTAS  MÀXIMO TOTAL CUOTA
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
  /*Para la siguiente vista deberán alterar el manejo de sesiones de usuario,
  el sistema deberá guardar el timestamp de la hora de sesión y el
  timestamp del fin de sesión, si el usuario tiene el campo fin de
  sesión en null, significa que la sesión está activa. Crear una
  vista que traiga las personas que tienen una sesión activa,
  ordenado por la hora de inicio de sesión, mostrando las personas
  que más tiempo llevan activas; adicional, deberá tener una columna
  que calcule cuántas horas lleva en el sistema con respecto a la hora actual,
  la siguiente columna será la cantidad de horas seleccionada en las
  preferencias de usuario, finalmente, habrá una columna que reste
  cuánto tiempo le falta para que se cierre la sesión.
  (si aparece un valor negativo, significa que el usuario excedió el tiempo en el sistema)*/
  
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