CREATE TABLE EMPLOYEE (
  Employee VARCHAR(50) NOT NULL,
  Sick_pop INT NOT NULL,
  Month_absent INT NOT NULL,
  Late_count INT NOT NULL,
  Cash_difference INT NOT NULL,
  EFT_difference INT NOT NULL,
  PRIMARY KEY (Employee)
  )
  ;
  
  INSERT INTO employee 
  (Employee, Sick_pop, Month_absent, Late_count, Cash_difference, EFT_Difference)
  VALUES
  ("Employee_1",8,2,12,500,0),
  ("Employee_2",5,1,1,100,10), 
  ("Employee_3",2,0,0,0,50),  
  ("Employee_4",0,0,5,20,90), 
  ("Employee_5",7,5,7,50,10)
  ;


SELECT
  r.Employee
  , r.Sick_pop
  , r.Month_absent
  , r.Late_count
  , r.Cash_difference
  , r.EFT_difference 
  , r.RR1
  , r.RR2
  , r.RR3
  , cast((r.RR1 + r.RR2 + r.RR3)/3 as decimal(12,0)) AS Final_risk_score
 FROM
     (SELECT
      t01.Employee
      , t01.Sick_pop
      , t01.Month_absent
      , t01.Late_count
      , t01.Cash_difference
      , t01.EFT_difference
      , t01.RR1
      , t01.RR2
      , CASE WHEN (cnt_cash+cnt_EFT) = 0 THEN 0
        ELSE Cast(1.00*(Total_score_3/(cnt_cash+cnt_EFT)) AS DECIMAL(12,0)) END AS RR3

      FROM
          (SELECT
            a.Employee
            , a.Sick_pop
            , a.Month_absent
            , a.Late_count
            , a.Cash_difference
            , a.EFT_difference

              , CASE WHEN Risk_Score_1+Risk_Score_2 = 3 THEN 3
                              WHEN Risk_Score_1+Risk_Score_2 = 2 THEN 2
                              WHEN Risk_Score_1+Risk_Score_2 = 1 THEN 1
                              ELSE 0          
              END AS RR1
            , a.RR2
            , a.Cash_score + a.EFT_Score as Total_score_3
            , CASE WHEN a.Cash_score >0 THEN 1 ELSE 0 END AS cnt_cash
            , CASE WHEN a.EFT_score >0 THEN 1 ELSE 0 END AS cnt_EFT

          FROM
              (SELECT
                Employee
                , Sick_pop
                , Month_absent
                , Late_count
                , Cash_difference
                , EFT_difference
                , CASE WHEN sick_pop >6 THEN 2 
                              WHEN sick_pop <=5 THEN 1 ELSE 0 END AS Risk_Score_1 
                , CASE WHEN Month_absent>1 THEN 1 ELSE 0 END AS Risk_Score_2 
                , CASE 
                              WHEN Late_count >=12 THEN 3 
                              WHEN Late_count BETWEEN 6 AND 11 THEN 2               
                              WHEN Late_count BETWEEN 3 AND 5 THEN 1
                              ELSE 0
                  END AS RR2    
                
                   , CASE 
                              WHEN Cash_difference >=300 THEN 3   
                              WHEN Cash_difference BETWEEN 100 AND 299 THEN 2             
                              WHEN Cash_difference BETWEEN 50 AND 99 THEN 1
                              ELSE 0
                  END AS Cash_score
                  , CASE 
                              WHEN EFT_difference >=300 THEN 3 
                              WHEN EFT_difference BETWEEN 100 AND 299 THEN 2               
                              WHEN EFT_difference BETWEEN 50 AND 99 THEN 1
                              ELSE 0
                  END AS EFT_score
               
               
                FROM  EMPLOYEE
                ) a
           )t01
   ) r
ORDER BY 1
;