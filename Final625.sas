*****************************************************************************************
* SAS Program Name: SAS BRFSS 10 LSATISFY and INCOME2  
* The objective of this analysis is to investigate the association of responders reporting
* satisfaction with life (LSATISFY) and income level (INCOME2) after controlling for quality 
* of age (AGE) and education level (EDUCA) in BRFSS 2010 responders who were 18-65 year olds.
*****************************************************************************************;
LIBNAME TRANSPRT XPORT '/folders/myshortcuts/brfss-2010/CDBRFS10.XPT';
LIBNAME DATAOUT '/folders/myshortcuts/brfss-2010/';

* pass copy of dataset to dataout;
PROC COPY IN=TRANSPRT OUT=DATAOUT;
RUN;

DATA temp;
	set dataout.CDBRFS10 (where=( (EDUCA in (1,2,3,4,5,6)) and (_INCOMG in (1,2,3,4,5)) and (SEX in (1,2)) and 
		(18<=AGE<=65) and (LSATISFY in (1,2,3,4)) ));
	
	if SEX in (1) then gender = 1;
	if SEX in (2) then gender = 0;
	
	if EDUCA in (1,2,3) then college = 0;
	if EDUCA in (4,5,6) then college = 1;
	
	if (18<=age<35) then agecat = 1;
	if (35<=age<50) then agecat = 2;
	if (50<=age<=65) then agecat = 3;
	
	if _INCOMG in (1,2,3,4) then income = 1;
	if _INCOMG in (5) then income = 2;
		
	if LSATISFY in (1,2) then satisfied = 1;
	if LSATISFY in (3,4) then satisfied = 0;	
RUN;

* format gender;
PROC FORMAT;
	value college
	0 = 'NO'
	1 = 'YES'
	;	
	value agecategory
	1 = '18<=age<=35'
	2 = '36<=age<=50'
	3 = '51<=age<=65'
	;	
	value income
	1 = '< $50,000'
	2 = '> $50,000'
	;	
	value gender
	1 = 'Male'
	0 = 'Female'
	;
	value satisfied
	1 = 'Satisfied'
	2 = 'Not satisfied'
	;
RUN;

PROC FREQ data=temp;
	table gender;
	Format gender gender.
RUN;

PROC FREQ data=temp;
	**table 1, univariate and descriptive statistics;
	title 'Table 1: Univariate and descriptive statistics';
	tables (college agecat sex)*income/ chisq;
	Format college college. AGE agecategory. income income. gender gender.;
RUN;

PROC FREQ data=temp;
	**table 2, univariate and descriptive statistics;
	title 'Table 2: Univariate and descriptive statistics';
	tables (college agecat income sex)*satisfied / chisq;
	Format college college. AGE agecategory. income income. satisfied satisfied. gender gender. ;
RUN;

PROC LOGISTIC data=temp;
	**table 3, multivariable logistic regression analysis;
	title 'Table 3: Multivariable Logistic Regression';
	class satisfied (ref='1') agecat (ref='1') income (ref='1') college (ref='0') gender (ref = '0') satisfied (ref='1') / param = ref;
	model satisfied = income agecat college gender / lackfit;	
RUN;

PROC REG data=temp;
title 'Variance Inflation Factors';
	model satisfied = agecat income college sex / vif tol;
	Format college college. AGE agecategory. income income. satisfied satisfied. gender gender. ;

RUN;




