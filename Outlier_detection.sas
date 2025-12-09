/*dataset "/home/u64327440/DATA/Clinical_Project - Lab_data.xlsx"*/

proc import datafile= "/Clinical_Project - Lab_data.xlsx" out = clinical_project 
dbms=XLSX  
replace;
getnames=yes;
run;
proc print data=clinical_project;run;


/*sort by LBTEST USUBJID*/

proc sort data=clinical_project out=sorted_by_test;
by LBTEST USUBJID;
run;

/*Create two dataset by seperatig by LBTEST "Hemoglob Glucose"*/

data hemoglob_data;
set sorted_by_test;
where LBTEST = "Hemoglob";
drop obs;
run;
proc print data=hemoglob_data;run;



data glucose_data;
set sorted_by_test;
where LBTEST = "Glucose";
drop obs;
run;
proc print data=glucose_data;run;

/* Obs 	USUBJID 	LBTEST 	LBSTRESN 	LBSTNRLO 	LBSTNRHI 	LBSTRESU 	LBDTC */
/*outlier detection*/


data hemoglob_data;
set hemoglob_data;
if LBSTRESN < LBSTNRLO or LBSTRESN > LBSTNRHI then Outlier  = "Raise query";
else Outlier  = "Valid entry";
run;
proc print data=hemoglob_data; Title Hemoglob_dataset ;run;


data glucose_data;
set glucose_data;
if LBSTRESN < LBSTNRLO or LBSTRESN > LBSTNRHI then Outlier  = "Raise query";
else Outlier  = "Valid entry";
run;
proc print data=glucose_data;Title Glucose_dataset ;run;




/*-----DESCRIPTIVE STATISTICS USING PROC MEANS----------*/

TITLE "Overall Glucose Statistics";
PROC MEANS DATA=glucose_data N MEAN MEDIAN STD MIN MAX MAXDEC=2;
    VAR LBSTRESN;
RUN;


proc freq data=glucose_data;
table USUBJID;
run;


/* Statistics by Outlier Status */
TITLE "Glucose Statistics by Outlier Flag";
PROC MEANS DATA=glucose_data N MEAN MEDIAN STD MIN MAX MAXDEC=2;
    CLASS Outlier;
    VAR LBSTRESN;
RUN;


/* Identify high and low glucose readings */


proc sql;
create table glucose_data_with_status as
select *,
case
when LBSTRESN < LBSTNRLO then "Low"
when LBSTRESN > LBSTNRHI then "High"
else "Normal"
End as Range_status
from glucose_data;
quit; 

/* Statistics by Range Status */
TITLE "Glucose Statistics by Range Flag";
PROC MEANS DATA=glucose_data_with_status N MEAN MEDIAN STD MIN MAX MAXDEC=2;
CLASS Range_status;
VAR LBSTRESN;
RUN;



/*SGPLOT*/


PROC SGPLOT DATA=SASHELP.CLASS;
VBOX HEIGHT / CATEGORY=SEX;
TITLE "BOX PLOT OF HEIGHT BY GENDER";
RUN;



/* Box plot by subject */
TITLE "Glucose Levels Box Plot by Subject";
PROC SGPLOT DATA=glucose_data;
    VBOX LBSTRESN / GROUP=USUBJID;
    REFLINE 70 / AXIS=Y LINEATTRS=(COLOR=GREEN);
    REFLINE 110 / AXIS=Y LINEATTRS=(COLOR=GREEN);
    YAXIS LABEL="Glucose (mg/dL)";
RUN;

/* Histogram of glucose distribution */
TITLE "Distribution of Glucose Values";
PROC SGPLOT DATA=glucose_data;
    HISTOGRAM LBSTRESN;
    DENSITY LBSTRESN;
    XAXIS LABEL="Glucose (mg/dL)";
    YAXIS LABEL="Frequency";
RUN;

/* Box plot by outlier status */
TITLE "Glucose Distribution: Valid vs Flagged Data";
PROC SGPLOT DATA=glucose_data;
    VBOX LBSTRESN / GROUP=Outlier;
    XAXIS LABEL="Data Quality Status";
    YAXIS LABEL="Glucose (mg/dL)";
RUN;



/* Scatter plot of glucose levels with normal range reference */
TITLE "Glucose Levels vs Subject ID";
PROC SGPLOT DATA=glucose_data;
    SCATTER X=USUBJID Y=LBSTRESN / GROUP=Outlier;
    REFLINE 70 / AXIS=Y LABEL="Lower Normal" LINEATTRS=(COLOR=GREEN);
    REFLINE 110 / AXIS=Y LABEL="Upper Normal" LINEATTRS=(COLOR=GREEN);
    XAXIS LABEL="Subject ID";
    YAXIS LABEL="Glucose (mg/dL)";
RUN;



/*1. EXCEL*/

ODS EXCEL FILE="/SAS SQL/glucose_data.xlsx";
PROC REPORT DATA=glucose_data;
TITLE "glucose_data REPORT";
FOOTNOTE "END";
RUN;
ODS EXCEL CLOSE;












