# utl_trajectory_of_drug_beneficiaries_for_general_practice_physicians
Trajectory of Drug Beneficiaries for General Practice Physicians. Keywords: sas sql join merge big data analytics macros oracle teradata mysql sas communities stackoverflow statistics artificial inteligence AI Python R Java Javascript WPS Matlab SPSS Scala Perl C C# Excel MS Access JSON graphics maps NLP natural language processing machine learning igraph DOSUBL DOW loop stackoverflow SAS community.
     PROJECT TOKEN = phy

     %let purpose=Trajectory of Drug Beneficiaries for General Practice Physicians

     THIS IS A WORK IN PROGRESS AND MAY BE VERY BUGGY (DRAFT MODEL)

     github
     https://tinyurl.com/ybz3a643


     libname phy "d:/phy";

     options  validvarname=upcase fmtsearch=(phy.phy_formats work.formats);

     %let _r = c:;

     %let pgmloc = &_r\utl; * location of this program;

     Windows Local workstation SAS 9.3M1(64bit) Win 7(64bit) Dell T7400 64gb ram, dual SSD raid 0 arrays, 8 core

     PROGRAM VERSIONSING c:\ver

     This program  does the following (use at your own risk analysis in progress)

      1. Converts SUMMARY Public Use Files  https://goo.gl/2Vpj86 to SAS tables

           Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2015..txt
           Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2014..txt
           Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2013.xlsx
           Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2012.xlsx
      2. Converts DETAIL  Public Use Files  https://goo.gl/2Vpj86 to SAS tables

           Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2015..txt
           Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2014..txt
           Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2013.xlsx
           Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2012.xlsx

      3.   Proc traj on percent Drug Beneficiates


     OVERVIEW
     ========

     Macros (many of thes macros are for QC)

       utl_ymrlan100    template for PDF and PPT slides
       pdfbeg           start slide creation
       pdfend           end slide preparation
       utlopts          turn options on
       utlnopts         turn options off
       varlist          create list of variable names
       do_over          SAS %do in open code                    ( https://tinyurl.com/ybz3a643)
       array            used with do_over but can be used alone ( https://tinyurl.com/ybz3a643)
       greenbar         highlight alternate rows in proc report
       tut_sly          like SASWEAVE or knitr https://github.com/rogerjdeangelis/SASweave
       voodoo           validation and verification of table columns and rows
                           (https://github.com/rogerjdeangelis/voodoo
       renamel          https://github.com/rogerjdeangelis/utl_rename_coordinated_lists_of_variables

     Dimension tables (formats)
     ==========================

       phy_formats.sas7bdat



     DRIVER macros (sequenc for running jobs)
     ========================================

     After development, I usually split log programs like this into several programs.

      Macros

      ie taj_100cmsSum.sas  Summary
         taj_200cmsDet.sas  Detail
         taj_300cmsTaj.sas  Trajectory analysis

      The driver program taj_000Dvr.sas just calls macro progs above

      Contents of macro driver taj_000Dvr.sas

       systask kill sys1 sys2  ;
        systask command "&_s -termstmt %nrstr(%taj_100cmsSum) -log d:\taj\log\taj_100cmsSum&sysdate..log" task=sys1;
        systask command "&_s -termstmt %nrstr(%taj_200cmsDet) -log d:\taj\log\taj_100cmsSum&sysdate..log" task=sys2;
       waitfor sys1 sys2;

       %taj_300cmsTaj; * run after above;



     DEPENDENCIES  (autocall library and autoexec with password)
     =============
     autocall &_r/oto

    ================================================================================================================


     INPUTS
     =======

      https://goo.gl/2Vpj86
      https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports
        /Medicare-Provider-Charge-Data/Physician-and-Other-Supplier.html

      http://2015.padjo.org/tutorials/sql-walks/exploring-wsj-medicare-investigation-with-sql/

      How the NPI number is used to associate medical providers with services and reimbursements.
      How to find the total number of Medicare patients a medical provider had in 2012.
      How to find every procedure and treatment that any given doctor billed to Medicare.
      How to calculate how much Medicare actually reimbursed a given doctor for their services.
      How to calculate the average number of times a given procedure was administered in a day,
      or per patient – is it notable when a doctor administers a procedure at a much higher rate
      than his/her peers?
      Many of the text fields are not very reliable.
      The HCPCS description field can be quite vague.

      https://goo.gl/2Vpj86
      https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports
        /Medicare-Provider-Charge-Data/Physician-and-Other-Supplier.html

      MEDICARE PUBLIC USE FILES

       Summary data NPI level

        TAB DELIMITED

         d:\phy\txt\Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2015..txt
         d:\phy\txt\Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2014..txt

        XLSX
         d:/phy/xls/Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2013.xlsx
         d:/phy/xls/Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2012.xlsx

        DETAIL CLAIMS

         d:\phy\txt\Medicare_Provider_Util_Payment_PUF_CY2012.TXT
         d:\phy\txt\Medicare_Provider_Util_Payment_PUF_CY2013.TXT
         d:\phy\txt\Medicare_Provider_Util_Payment_PUF_CY2014.TXT
         d:\phy\txt\Medicare_Provider_Util_Payment_PUF_CY2015.TXT


     OUTPUT
     ===========================

       2012-2015 Summary Claims (NPI primary key)

          PHY.PHY_100CMS_TABNPISUM   TAB Summary of 2014-2015 medicare files
          PHY.PHY_100CMS_XLSNPISUM   XLS Summary of 2012-2013 medicare files

          PHY.PHY_100CMS_NPISUM      XLS & TAB All summary data 2012-2015 xls files combined tab file

          PHY.PHY_100CMS_SUMADDRESS     PHY.PHY_100CMS_NPISUM Dimension data like address
          PHY.PHY_100CMS_SUMFACTS       PHY.PHY_100CMS_NPISUM Fact data like dollars and percents

      SUMMARY Trajectory Analysis

     Proc traj output

     %let pdf2ppt=d:\exe\p2p\pdftopptcmd.exe;      * free boxoft pdf to ppt converter executable                   ;
                                                                                                                   ;
     %let wevoutpdf=d:\phy\pdf\&pgm..pdf;          * output pdf;                                                   ;
     %let wevoutppt=d:\phy\ppt\&pgm..ppt;          * free boxoft will convert this output to appt;                 ;


