
set serveroutput on;



UPDATE MATCH_  SET STATUS = 'FINALIZADO' WHERE ID_MATCH = 1;

--------------------------------------------------------------------------------------------------------------------------------------------3-----------------------------------------------------------------------------------------------------------

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
                ELSIF NAME_CATE= '¿AMBOS ANOTARAN GOL?' THEN
                    IF T_GOALT1 >  0 AND T_GOALT2 > 0 THEN
                        W_QTA := 2;
                    ELSE
                        W_QTA := 3;
                    END IF;
                ELSIF NAME_CATE= '¿QUIEN GANA EL 1ER TIEMPO' THEN
                    IF H_GOALT1 > H_GOALT2 THEN
                        W_QTA := 1;
                    ELSIF H_GOALT1 < H_GOALT2 THEN
                        W_QTA := 3;
                    ELSE
                        W_QTA := 2;
                    END IF;
                ELSIF NAME_CATE= '¿QUIEN GANA EL 2DO TIEMPO' THEN
                    IF T_GOALT1 > T_GOALT2 THEN
                        W_QTA := 1;
                    ELSIF T_GOALT1 < T_GOALT2 THEN
                        W_QTA := 3;
                    ELSE
                        W_QTA := 2;
                    END IF;
                ELSIF NAME_CATE= '¿HAY POR LO MENOS UN GOL EN CADA TIEMPO?' THEN
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

--------------------------------------------------------------------------------------------------------------------------------------------4-----------------------------------------------------------------------------------------------------------