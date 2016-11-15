*****************************************************************************************
* SAS Program Name: SAS BRFSS 10 _bmi4cat and DIABETE2  
* The objective of this analysis is to investigate the association between diabetes and 
* BMI after controlling for physical activity (exercise), gender, general health, lifetime 
* smoking, and healthcare coverage.  The outcome variable is diabetes and the variable of 
* interest (exposure variable) is BMI.
*****************************************************************************************;
LIBNAME TRANSPRT XPORT '/folders/myshortcuts/brfss-2010/CDBRFS10.XPT';
LIBNAME DATAOUT '/folders/myshortcuts/brfss-2010/';

* pass copy of dataset to dataout;
PROC COPY IN=TRANSPRT OUT=DATAOUT;
RUN;

DATA temp;
	set dataout.cdbrfs10 (where=((DIABETE2 in (1,3)) and (_BMI4CAT in (1,2,3)) and (EXERANY2 in (1,2)) and (SEX in (1,2))  
		and (GENHLTH in (1,2,3,4,5)) and (_RFSMOK3 in (1,2)) and (HLTHPLAN in (1,2)) ));
	if DIABETE2 in (3) then	DIABETE2 = 0; 		*answered 'no' to DIABETE2 ;
	if DIABETE2 in (1) then	DIABETE2 = 1; 		*answered 'yes' to DIABETE2 ;	
	if _BMI4CAT in (1) then _BMI4CAT = 0; 		*answered 'no' to obese/overweight ;
	if _BMI4CAT in (2,3) then _BMI4CAT = 1; 	*answered 'yes' to obese/overweight ;
	if exerany2 in (2) then exerany2 = 0;		*answered 'no' to exercising ;
	if exerany2 in (1) then exerany2 = 1;		*answered 'yes' to exercising ;
	if sex in (1) then sex = 1;					*answered male ;
	if sex in (2) then sex = 0;					*answered female ;
	if HLTHPLAN in (1) then HLTHPLAN = 1;		*answered 'yes' to health care access ;
	if HLTHPLAN in (2) then HLTHPLAN = 0;		*answered 'no' to health care access ;
	if _RFSMOK3 in (1) then _RFSMOK3 = 1;		*answered 'yes' to lifetime smoker ;
	if _RFSMOK3 in (2) then _RFSMOK3 = 0;		*answered 'no' to lifetime smoker ;
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
	
	value healthplan
	1 = 'Healthcare access (YES)'
	0 = 'Healthcare access (NO)'	
	;
	
	value smoker
	1 = 'Smoker (YES)'
	0 = 'Smoker (NO)'
	;
	
	value genhlth
	1 = Excellent
	2 = Very Good
	3 = Good
	4 = Fair
	5 = Poor
	;
	
RUN;

* variable tables;
PROC FREQ data=temp;
	title 'Tables';
	tables SEX _BMI4CAT EXERANY2 GENHLTH HLTHPLAN DIABETE2 ;
	Format SEX SEX. EXERANY2 exercise. DIABETE2 diabetes. _BMI4CAT bmi. ;
RUN;

PROC FREQ data=temp;
	**table 2 descriptive statistics;
	title 'Table 2: BMI, Exercise, and Gender by DIABETE2 ';
	tables (_BMI4CAT EXERANY2 SEX GENHLTH HLTHPLAN)*DIABETE2 / chisq;
	Format SEX SEX. EXERANY2 exercise. _BMI4CAT bmi. DIABETE2 diabetes. ;
RUN;

PROC LOGISTIC data=temp;
	**table 3, multivariable logistic regression analysis;
	title 'Table 3: Multivariable Logistic Regression';
	class DIABETE2 (ref='1') _BMI4CAT (ref='1') EXERANY2 (ref='1') SEX (ref='1') GENHLTH (ref='1') HLTHPLAN (ref='1') _RFSMOK3(ref='0') / param = ref;
	model DIABETE2 = _BMI4CAT EXERANY2 SEX GENHLTH HLTHPLAN _RFSMOK3 / lackfit;		
RUN;

PROC REG data=temp;
    model DIABETE2 = _BMI4CAT EXERANY2 SEX GENHLTH HLTHPLAN _RFSMOK3 / vif tol;    
RUN;
