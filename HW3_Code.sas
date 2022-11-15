***************Homework_3: How Far Do My Customers Travel***************;
***********My Computer Libname**************
*Creating library from HW3_Data file and accessing excel data sets using proc import;
libname HW3SAS "C:\Users\bprom19\Desktop\ECON 673 HW Data\HW_3";

PROC IMPORT DATAFILE="C:\Users\bprom19\Desktop\ECON 673 HW Data\HW_3\Location Lat Long Data.xlsx" 
		DBMS=xlsx out=work.LatLong replace;
	sheet="Location Lat Long Data";
RUN;

/*
 *****TAMU Computer Lab**************;
libname HW3SAS "H:\Econ 673\Homework 3\HW3_Data";;

PROC IMPORT
DATAFILE= "H:\Econ 673\Homework 3\HW3_Data\Location Lat Long Data.xlsx"
DBMS= xlsx
out = work.LatLong replace;
sheet="Location Lat Long Data";
RUN;
 */
*sorting data sets, HW3SAS and LatLong by location ID;
* And them merge those two data sets by Location_ID output to HW3_Data;

proc sort data=HW3SAS.HW3_Data out=HW3;
	by location_id;
run;

proc sort data=latlong;
	by location_id;
run;

*Use GEODIST function to calculate the straight-line distace (measured in miles)

	 traveled by each customer to the retail location;

data HW3_DATA;
	merge HW3 LatLong;
	by Location_ID;
	Miles=GEODIST(latitude, longitude, ref_latitude, ref_longitude, 'M');
run;

*Use accumulator variables and by-group processing to aggregate (sum)
 the quantity variable for each location_ID/Customer_ID combination

	 and to get an overall total for each location_ID;

proc sort data=hw3_data;
	by location_id customer_id;
run;

data Q2a;
	set hw3_data;
	by location_id customer_id;

	if first.customer_id then
		cus_quantity=0;
	cus_quantity+quantity;

	if last.customer_id;
run;

data Q2b;
	set hw3_data;
	by location_id customer_id;

	if first.location_id then
		loc_quantity=0;
	loc_quantity+quantity;

	if last.location_id;
run;

data Q3;
	set Hw3_data;
	by location_id;
	dist_class=0;

	do i=0.5 to 100 by 0.5;

		if i-0.5<=miles<i then
			dist_class=i;
		drop i;
	end;
run;

proc sort data=Q3;
	by location_id dist_class;
run;

data Q4;
	set Q3;
	by location_id dist_class;

	if first.dist_class then
		dist_total=0;
	dist_total+quantity;

	if last.dist_class;
run;

data Q5 (keep=location_id customer_id loc_quantity miles dist_class dist_total 
		salespercent totalpercent);
	merge Q2b Q4;
	by location_id;
	salespercent=(dist_total/loc_quantity);
	format salespercent percent8.2;

	if first.location_id then
		totalpercent=0;
	totalpercent+salespercent;
	format totalpercent percent8.2;
run;

*Area for at least 75% of sale;

Data Q6_75(keep=location_id dist_class totalpercent);
	set Q5;
	by location_id;
	where totalpercent >=.75;

	if first.location_id;
	output;
run;

Data Q6_90(keep=location_id dist_class totalpercent);
	set Q5;
	by location_id;
	where totalpercent >=.90;

	if first.location_id;
	output;
run;

data Q7(keep=location_id w_average);
	set Q5;
	by location_id;

	if first.location_id then
		do;
			weight=0;
			weight_tot=0;
		end;
	*cumulative;
	weight + dist_total;
	weight_tot + dist_total*dist_class;

	if last.location_id;
	w_average=weight_tot/weight;
run;

data final_answer;
	merge Q6_75 Q6_90 Q7;
	by location_id;
run;

/*
libname hw3out excel "C:\Users\bprom19\Desktop\ECON 673 HW Data\HW_3\HW3_Output.xlsx.xlsx";

data hw3out.summary;
set Q6_75;
run;
libname hw3out clear;


/*libname hw3_out excel "C:\Users\bprom19\OneDrive\TAMU\Fall 2022\Econ 673\HW\HW_3\HW3_output.xlsx";
data hw3_out.summary;
set Q5;
run;
