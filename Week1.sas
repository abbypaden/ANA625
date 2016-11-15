*****************************************************************************************
* SAS Program Name: SAS BRFSS 10 _bmi4cat and DIABETE2  
* The objective of this analysis is to investigate the association of DIABETE2 (DIABETE2 ) 
* and BMI (_BMI4CAT) after controlling for any physical activity (EXERANY2)
* and SEX (SEX) in a population of BRFSS 2010 responders who were 18-99 year olds.
*****************************************************************************************;
LIBNAME TRANSPRT XPORT '/folders/myshortcuts/brfss-2010/CDBRFS10.XPT';
LIBNAME DATAOUT '/folders/myshortcuts/brfss-2010/';

* pass copy of dataset to dataout;
PROC COPY IN=TRANSPRT OUT=DATAOUT;
RUN;

DATA temp;
	set dataout.cdbrfs10 (where=(((_BMI4CAT in (1,2,3))) and (SEX in (1,2)) and (DIABETE2 in (1,3)) and (EXERANY2 in (1,2))) );
	if DIABETE2 in (3) then	DIABETE2 = 0; 	*answered 'no' to DIABETE2 ;
	if DIABETE2 in (1) then	DIABETE2 = 1; 	*answered 'yes' to DIABETE2 ;	
	if _BMI4CAT in (1) then _BMI4CAT = 0; 	*answered 'no' to obese/overweight;
	if _BMI4CAT in (2,3) then _BMI4CAT = 1; 	*answered 'yes' to obese/overweight;
	if exerany2 in (2) then exerany2 = 0;
	if exerany2 in (1) then exerany2 = 1;
	if sex in (1) then sex = 1;
	if sex in (2) then sex = 0;
RUN;


DATA total;
	set dataout.cdbrfs10;	
RUN;

* format gender;
PROC FORMAT;
	value SEX
	1 = 'Male'
	0 = 'Female'
	;
	
	value bmi
	0 = 'Answered NO to obese/overweight'
	1 = 'Answered YES to obese/overweight'
	;
	
	value diabetes
	0 = 'Answered NO to diabetes'
	1 = 'Answered YES to diabetes'
	;
	
	value exercise
	1 = 'Exercised in last month (YES)'
	0 = 'Exercised in last month (NO)'
	;
RUN;

* variable tables;
PROC FREQ data=temp;
	title 'Tables';
	tables SEX _BMI4CAT EXERANY2 DIABETE2 ;
	Format SEX SEX. EXERANY2 exercise. DIABETE2 diabetes. _BMI4CAT bmi. ;
RUN;

*Gender vs. DIABETE2 (2x2);
PROC FREQ data=temp;
	title 'DIABETE2 by SEX (2x2)';
	tables DIABETE2*SEX;
	Format SEX SEX. DIABETE2 diabetes. ;
RUN;

*Gender vs. BMI (2x2);
PROC FREQ data=temp;
	title 'BMI by SEX (2x2)';
	tables _BMI4CAT*SEX;
	Format SEX SEX. _BMI4CAT bmi. ;
RUN;

*Gender vs. Exercise (2x2);
PROC FREQ data=temp;
	title 'Exercise by SEX (2x2)';
	tables EXERANY2*SEX;
	Format SEX SEX. EXERANY2 exercise. ;
RUN;

PROC FREQ data=temp;
	**table 1 descriptive statistics;
	title 'Table 1: Exercise and Gender by BMI';
	tables (EXERANY2 SEX)*_BMI4CAT / chisq;
	Format SEX SEX. _BMI4CAT bmi. EXERANY2 exercise. ;
RUN;

PROC FREQ data=temp;
	**table 2 descriptive statistics;
	title 'Table 2: BMI, Exercise, and Gender by DIABETE2 ';
	tables (_BMI4CAT EXERANY2 SEX)*DIABETE2 / chisq;
	Format SEX SEX. EXERANY2 exercise. _BMI4CAT bmi. DIABETE2 diabetes. ;
RUN;


PROC LOGISTIC data=temp;
	**table 3, multivariable logistic regression analysis;
	title 'Table 3: Multivariable Logistic Regression';
	class DIABETE2 (ref='1') _BMI4CAT (ref='1') EXERANY2 (ref='1') SEX (ref='0') / param = ref;
	model DIABETE2 = _BMI4CAT EXERANY2 SEX / lackfit;	
RUN;


