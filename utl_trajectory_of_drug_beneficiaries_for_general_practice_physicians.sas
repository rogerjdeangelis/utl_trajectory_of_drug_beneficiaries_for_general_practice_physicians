*******************************************************************************************************************;
*                                                                                                                 *;
*  PROJECT TOKEN = phy                                                                                            *;
*                                                                                                                 *;
*; %let purpose=Trajectory of Drug Beneficiaries for General Practice Physicians                                  *;
*                                                                                                                 *;
*  THIS IS A WORK IN PROGRESS AND MAY BE VERY BUGGY (DRAFT MODEL)                                                 *;
*                                                                                                                 *;
*  github                                                                                                         *;
*  https://tinyurl.com/ybz3a643                                                                                   *;
*                                                                                                                 *;
*                                                                                                                 *;
*; libname phy "d:/phy";                                                                                          *;
*                                                                                                                 *;
*; options  validvarname=upcase fmtsearch=(phy.phy_formats work.formats);                                         *;
*                                                                                                                 *;
*; %let _r = c:;                                                                                                  *;
*                                                                                                                 *;
*; %let pgmloc = &_r\utl; * location of this program;                                                             *;
*                                                                                                                 *;
*  Windows Local workstation SAS 9.3M1(64bit) Win 7(64bit) Dell T7400 64gb ram, dual SSD raid 0 arrays, 8 core    *;
*                                                                                                                 *;
*  PROGRAM VERSIONSING c:\ver                                                                                     *;
*                                                                                                                 *;
*  This program  does the following (use at your own risk analysis in progress)                                   *;
*                                                                                                                 *;
*   1. Converts SUMMARY Public Use Files  https://goo.gl/2Vpj86 to SAS tables                                     *;
*                                                                                                                 *;
*        Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2015..txt                                          *;
*        Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2014..txt                                          *;
*        Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2013.xlsx                                          *;
*        Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2012.xlsx                                          *;
*   2. Converts DETAIL  Public Use Files  https://goo.gl/2Vpj86 to SAS tables                                     *;
*                                                                                                                 *;
*        Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2015..txt                                          *;
*        Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2014..txt                                          *;
*        Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2013.xlsx                                          *;
*        Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2012.xlsx                                          *;
*                                                                                                                 *;
*   3.   Proc traj on percent Drug Beneficiates                                                                   *;
*                                                                                                                 *;
*                                                                                                                 *;
*  OVERVIEW                                                                                                       *;
*  ========                                                                                                       *;
*                                                                                                                 *;
*  Macros (many of thes macros are for QC)                                                                        *;
*                                                                                                                 *;
*    utl_ymrlan100    template for PDF and PPT slides                                                             *;
*    pdfbeg           start slide creation                                                                        *;
*    pdfend           end slide preparation                                                                       *;
*    utlopts          turn options on                                                                             *;
*    utlnopts         turn options off                                                                            *;
*    varlist          create list of variable names                                                               *;
*    do_over          SAS %do in open code                    ( https://tinyurl.com/ybz3a643)                     *;
*    array            used with do_over but can be used alone ( https://tinyurl.com/ybz3a643)                     *;
*    greenbar         highlight alternate rows in proc report                                                     *;
*    tut_sly          like SASWEAVE or knitr https://github.com/rogerjdeangelis/SASweave                          *;
*    voodoo           validation and verification of table columns and rows                                       *;
*                        (https://github.com/rogerjdeangelis/voodoo                                               *;
*    renamel          https://github.com/rogerjdeangelis/utl_rename_coordinated_lists_of_variables                *;
*                                                                                                                 *;
*  Dimension tables (formats)                                                                                     *;
*  ==========================                                                                                     *;
*                                                                                                                 *;
*    phy_formats.sas7bdat                                                                                         *;
*                                                                                                                 *;
*                                                                                                                 *;
*                                                                                                                 *;
*  DRIVER macros (sequenc for running jobs)                                                                       *;
*  ========================================                                                                       *;
*                                                                                                                 *;
*  After development, I usually split log programs like this into several programs.                               *;
*                                                                                                                 *;
*   Macros                                                                                                        *;
*                                                                                                                 *;
*   ie taj_100cmsSum.sas  Summary                                                                                 *;
*      taj_200cmsDet.sas  Detail                                                                                  *;
*      taj_300cmsTaj.sas  Trajectory analysis                                                                     *;
*                                                                                                                 *;
*   The driver program taj_000Dvr.sas just calls macro progs above                                                *;
*                                                                                                                 *;
*   Contents of macro driver taj_000Dvr.sas                                                                       *;
*                                                                                                                 *;
*    systask kill sys1 sys2  ;                                                                                    *;
*     systask command "&_s -termstmt %nrstr(%taj_100cmsSum) -log d:\taj\log\taj_100cmsSum&sysdate..log" task=sys1;*;
*     systask command "&_s -termstmt %nrstr(%taj_200cmsDet) -log d:\taj\log\taj_100cmsSum&sysdate..log" task=sys2;*;
*    waitfor sys1 sys2;                                                                                           *;
*                                                                                                                 *;
*    %taj_300cmsTaj; * run after above;                                                                           *;
*                                                                                                                 *;
*                                                                                                                 *;
*                                                                                                                 *;
*  DEPENDENCIES  (autocall library and autoexec with password)                                                    *;
*  =============                                                                                                  *;
*  autocall &_r/oto                                                                                               *;
*                                                                                                                 *;
* ================================================================================================================*;
*                                                                                                                 *;
*                                                                                                                 *;
*  INPUTS                                                                                                         *;
*  =======                                                                                                        *;
*                                                                                                                 *;
*   https://goo.gl/2Vpj86                                                                                         *;
*   https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports                        *;
*     /Medicare-Provider-Charge-Data/Physician-and-Other-Supplier.html                                            *;
*                                                                                                                 *;
*   http://2015.padjo.org/tutorials/sql-walks/exploring-wsj-medicare-investigation-with-sql/                      *;
*                                                                                                                 *;
*   How the NPI number is used to associate medical providers with services and reimbursements.                   *;
*   How to find the total number of Medicare patients a medical provider had in 2012.                             *;
*   How to find every procedure and treatment that any given doctor billed to Medicare.                           *;
*   How to calculate how much Medicare actually reimbursed a given doctor for their services.                     *;
*   How to calculate the average number of times a given procedure was administered in a day,                     *;
*   or per patient – is it notable when a doctor administers a procedure at a much higher rate                    *;
*   than his/her peers?                                                                                           *;
*   Many of the text fields are not very reliable.                                                                *;
*   The HCPCS description field can be quite vague.                                                               *;
*                                                                                                                 *;
*   https://goo.gl/2Vpj86                                                                                         *;
*   https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports                        *;
*     /Medicare-Provider-Charge-Data/Physician-and-Other-Supplier.html                                            *;
*                                                                                                                 *;
*   MEDICARE PUBLIC USE FILES                                                                                     *;
*                                                                                                                 *;
*    Summary data NPI level                                                                                       *;
*                                                                                                                 *;
*     TAB DELIMITED                                                                                               *;
*                                                                                                                 *;
*      d:\phy\txt\Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2015..txt                                 *;
*      d:\phy\txt\Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY2014..txt                                 *;
*                                                                                                                 *;
*     XLSX                                                                                                        *;
*      d:/phy/xls/Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2013.xlsx                                 *;
*      d:/phy/xls/Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2012.xlsx                                 *;
*                                                                                                                 *;
*     DETAIL CLAIMS                                                                                               *;
*                                                                                                                 *;
*      d:\phy\txt\Medicare_Provider_Util_Payment_PUF_CY2012.TXT                                                   *;
*      d:\phy\txt\Medicare_Provider_Util_Payment_PUF_CY2013.TXT                                                   *;
*      d:\phy\txt\Medicare_Provider_Util_Payment_PUF_CY2014.TXT                                                   *;
*      d:\phy\txt\Medicare_Provider_Util_Payment_PUF_CY2015.TXT                                                   *;
*                                                                                                                 *;
*                                                                                                                 *;
*  OUTPUT                                                                                                         *;
*  ===========================                                                                                    *;
*                                                                                                                 *;
*    2012-2015 Summary Claims (NPI primary key)                                                                   *;
*                                                                                                                 *;
*       PHY.PHY_100CMS_TABNPISUM   TAB Summary of 2014-2015 medicare files                                        *;
*       PHY.PHY_100CMS_XLSNPISUM   XLS Summary of 2012-2013 medicare files                                        *;
*                                                                                                                 *;
*       PHY.PHY_100CMS_NPISUM      XLS & TAB All summary data 2012-2015 xls files combined tab file               *;
*                                                                                                                 *;
*       PHY.PHY_100CMS_SUMADDRESS     PHY.PHY_100CMS_NPISUM Dimension data like address                           *;
*       PHY.PHY_100CMS_SUMFACTS       PHY.PHY_100CMS_NPISUM Fact data like dollars and percents                   *;
*                                                                                                                 *;
*   SUMMARY Trajectory Analysis                                                                                   *;
*                                                                                                                 *;
*  Proc traj output                                                                                               *;
*                                                                                                                 *;
*; %let pdf2ppt=d:\exe\p2p\pdftopptcmd.exe;      * free boxoft pdf to ppt converter executable                   ;*;
*;                                                                                                               ;*;
*; %let wevoutpdf=d:\phy\pdf\&pgm..pdf;          * output pdf;                                                   ;*;
*; %let wevoutppt=d:\phy\ppt\&pgm..ppt;          * free boxoft will convert this output to appt;                 ;*;
*                                                                                                                 *;
*                                                                                                                 *;
*******************************************************************************************************************;

 %let _s=%sysfunc(compbl(C:\Progra~1\SASHome\SASFoundation\9.4\sas.exe -sysin c:\nul
   -sasautos c:\oto -autoexec c:\oto\Tut_Oto.sas -work d:\wrk));

 systask kill sys1 sys2  ;
 systask command "&_s -termstmt %nrstr(%taj_100cmsSum) -log d:\taj\log\taj_100cmsSum&sysdate..log" taskname=sys1;
 systask command "&_s -termstmt %nrstr(%taj_100cmsSum) -log d:\taj\log\taj_100cmsSum&sysdate..log" taskname=sys2;
 waitfor sys1 sys2;

data tst;
  b222=-3768490;
  b22=-3844820;
  b222c=-3767578;
  b2222=-3736304;
  ans22   =  log(2 * (b22    - b22 ));
  ans222  =  log(2 * (b222   - b22 ));
  ans2222 =  log(2 * (b2222  - b22 ));
  ans222c=   log(2 * (b222c  - b22 ));
run;quit;

ANS22     ANS222    ANS2222    ANS222C

  .      11.9360    12.2878    11.9478


*
 _ __ ___   __ _  ___ _ __ ___  ___
| '_ ` _ \ / _` |/ __| '__/ _ \/ __|
| | | | | | (_| | (__| | | (_) \__ \
|_| |_| |_|\__,_|\___|_|  \___/|___/

;
proc datasets library=work kill;
run;quit;;

%Macro utl_ymrlan100
    (
      style=utl_ymrlan100
      ,frame=void
      ,TitleFont=13pt
      ,docfont=13pt
      ,fixedfont=12pt
      ,rules=none
      ,bottommargin=.25in
      ,topmargin=.25in
      ,rightmargin=.25in
      ,leftmargin=.25in
      ,cellheight=13pt
      ,cellpadding = .2pt
      ,cellspacing = .2pt
      ,borderwidth = .2pt
    ) /  Des="SAS PDF Template for PDF";

ods path work.templat(update) sasuser.templat(update) sashelp.tmplmst(read);

proc template ;
source styles.printer;
run;quit;

Proc Template;

   define style &Style;
   parent=styles.rtf;

        class body from Document /

               protectspecialchars=off
               asis=on
               bottommargin=&bottommargin
               topmargin   =&topmargin
               rightmargin =&rightmargin
               leftmargin  =&leftmargin
               ;

        class color_list /
              'link' = blue
               'bgH'  = _undef_
               'fg'  = black
               'bg'   = _undef_;

        class fonts /
               'TitleFont2'           = ("Arial, Helvetica, Helv",&titlefont,Bold)
               'TitleFont'            = ("Arial, Helvetica, Helv",&titlefont,Bold)

               'HeadingFont'          = ("Arial, Helvetica, Helv",&titlefont)
               'HeadingEmphasisFont'  = ("Arial, Helvetica, Helv",&titlefont,Italic)

               'StrongFont'           = ("Arial, Helvetica, Helv",&titlefont,Bold)
               'EmphasisFont'         = ("Arial, Helvetica, Helv",&titlefont,Italic)

               'FixedFont'            = ("Courier New, Courier",&fixedfont)
               'FixedEmphasisFont'    = ("Courier New, Courier",&fixedfont,Italic)
               'FixedStrongFont'      = ("Courier New, Courier",&fixedfont,Bold)
               'FixedHeadingFont'     = ("Courier New, Courier",&fixedfont,Bold)
               'BatchFixedFont'       = ("Courier New, Courier",&fixedfont)

               'docFont'              = ("Arial, Helvetica, Helv",&docfont)

               'FootFont'             = ("Arial, Helvetica, Helv", 9pt)
               'StrongFootFont'       = ("Arial, Helvetica, Helv",8pt,Bold)
               'EmphasisFootFont'     = ("Arial, Helvetica, Helv",8pt,Italic)
               'FixedFootFont'        = ("Courier New, Courier",8pt)
               'FixedEmphasisFootFont'= ("Courier New, Courier",8pt,Italic)
               'FixedStrongFootFont'  = ("Courier New, Courier",7pt,Bold);

        class GraphFonts /
               'GraphDataFont'        = ("Arial, Helvetica, Helv",&fixedfont)
               'GraphValueFont'       = ("Arial, Helvetica, Helv",&fixedfont)
               'GraphLabelFont'       = ("Arial, Helvetica, Helv",&fixedfont,Bold)
               'GraphFootnoteFont'    = ("Arial, Helvetica, Helv",8pt)
               'GraphTitleFont'       = ("Arial, Helvetica, Helv",&titlefont,Bold)
               'GraphAnnoFont'        = ("Arial, Helvetica, Helv",&fixedfont)
               'GraphUnicodeFont'     = ("Arial, Helvetica, Helv",&fixedfont)
               'GraphLabel2Font'      = ("Arial, Helvetica, Helv",&fixedfont)
               'GraphTitle1Font'      = ("Arial, Helvetica, Helv",&fixedfont)
               'NodeDetailFont'       = ("Arial, Helvetica, Helv",&fixedfont)
               'NodeInputLabelFont'   = ("Arial, Helvetica, Helv",&fixedfont)
               'NodeLabelFont'        = ("Arial, Helvetica, Helv",&fixedfont)
               'NodeTitleFont'        = ("Arial, Helvetica, Helv",&fixedfont);


        style Graph from Output/
                outputwidth = 100% ;

        style table from table /
                outputwidth=100%
                protectspecialchars=off
                asis=on
                background = colors('tablebg')
                frame=&frame
                rules=&rules
                cellheight  = &cellheight
                cellpadding = &cellpadding
                cellspacing = &cellspacing
                bordercolor = colors('tableborder')
                borderwidth = &borderwidth;

         class Footer from HeadersAndFooters

                / font = fonts('FootFont')  just=left asis=on protectspecialchars=off ;

                class FooterFixed from Footer
                / font = fonts('FixedFootFont')  just=left asis=on protectspecialchars=off;

                class FooterEmpty from Footer
                / font = fonts('FootFont')  just=left asis=on protectspecialchars=off;

                class FooterEmphasis from Footer
                / font = fonts('EmphasisFootFont')  just=left asis=on protectspecialchars=off;

                class FooterEmphasisFixed from FooterEmphasis
                / font = fonts('FixedEmphasisFootFont')  just=left asis=on protectspecialchars=off;

                class FooterStrong from Footer
                / font = fonts('StrongFootFont')  just=left asis=on protectspecialchars=off;

                class FooterStrongFixed from FooterStrong
                / font = fonts('FixedStrongFootFont')  just=left asis=on protectspecialchars=off;

                class RowFooter from Footer
                / font = fonts('FootFont')  asis=on protectspecialchars=off just=left;

                class RowFooterFixed from RowFooter
                / font = fonts('FixedFootFont')  just=left asis=on protectspecialchars=off;

                class RowFooterEmpty from RowFooter
                / font = fonts('FootFont')  just=left asis=on protectspecialchars=off;

                class RowFooterEmphasis from RowFooter
                / font = fonts('EmphasisFootFont')  just=left asis=on protectspecialchars=off;

                class RowFooterEmphasisFixed from RowFooterEmphasis
                / font = fonts('FixedEmphasisFootFont')  just=left asis=on protectspecialchars=off;

                class RowFooterStrong from RowFooter
                / font = fonts('StrongFootFont')  just=left asis=on protectspecialchars=off;

                class RowFooterStrongFixed from RowFooterStrong
                / font = fonts('FixedStrongFootFont')  just=left asis=on protectspecialchars=off;

                class SystemFooter from TitlesAndFooters / asis=on
                        protectspecialchars=off just=left;
    end;
run;
quit;

%Mend utl_ymrlan100;
%utl_ymrlan100;




%Macro Tut_Sly
(
 stop=43,
 L1=' ',  L43=' ',  L2=' ', L3=' ', L4=' ', L5=' ', L6=' ', L7=' ', L8=' ', L9=' ',
 L10=' ', L11=' ',
 L12=' ', L13=' ', L14=' ', L15=' ', L16=' ', L17=' ', L18=' ', L19=' ',
 L20=' ', L21=' ',
 L22=' ', L23=' ', L24=' ', L25=' ', L26=' ', L27=' ', L28=' ', L29=' ', L30=' ', L31=' ', L32=' ',
 L33=' ', L34=' ', L35=' ', L36=' ', L37=' ', L38=' ', L39=' ', L40=' ', L41=' ', L42=' ',
 L44=' ', L45=' ', L46=' ', L47=' ', L48=' ', L49=' ', L50=' ', L51=' ', L52=' '
 )/ des="SAS Slides all argument values need to be single quoted";

/* creating slides for a presentation */
/* up to 32 lines */
/* backtic ` is converted to a single quote  */
/* | is converted to a , */

Data _OneLyn1st(rename=t=title);

Length t $255;
 t=resolve(translate(&L1,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
 t=resolve(translate(&L2,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
 t=resolve(translate(&L3,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
 t=resolve(translate(&L4,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
 t=resolve(translate(&L5,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
 t=resolve(translate(&L6,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
 t=resolve(translate(&L7,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
 t=resolve(translate(&L8,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
 t=resolve(translate(&L9,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L10,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L11,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L12,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L13,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L14,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L15,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L16,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L17,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L18,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L19,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L20,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L21,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L22,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L23,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L24,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L25,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L26,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L27,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L28,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L29,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L30,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L31,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L32,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L33,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L34,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L35,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L36,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L37,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L38,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L39,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L41,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L42,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L43,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L44,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L45,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L46,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L47,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L48,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L50,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L51,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;
t=resolve(translate(&L52,"'","`"));t=translate(t,",","|");t=translate(t,";","~");t=translate(t,'%',"#");t=translate(t,'&',"@");Output;

run;quit;

/*  %let l7='^S={font_size=25pt just=c cellwidth=100pct}Premium Dollars';  */

options label;
%if &stop=7 %then %do;
   data _null_;
      tyt=scan(&l7,2,'}');
      call symputx("tyt",tyt);
   run;
   ods pdf bookmarkgen=on bookmarklist=show;
   ods proclabel="&tyt";run;quit;
%end;
%else %do;
   ods proclabel="Title";run;quit;
%end;


data _onelyn;
  set _onelyn1st(obs=%eval(&stop + 1));
  if not (left(title) =:  '^') then do;
     pre=upcase(scan(left(title),1,' '));
     idx=index(left(title),' ');
     title=substr(title,idx+1);
  end;
  put title;
run;

* display the slide ;
title;
footnote;

proc report data=_OneLyn nowd  style=utl_pdflan100;
col title;
define title / display ' ';
run;
quit;

%Mend Tut_Sly;

%macro utl_boxpdf2ppt(inp=&outpdf001,out=&outppt001)/des="www.boxoft.con pdf to ppt";
  data _null_;
    cmd=catt("&pdf2ppt",' "',"&inp", '"',' "',"&out",'"');
    put cmd;
    call system(cmd);
  run;
%mend utl_boxpdf2ppt;

%MACRO greenbar ;
   DEFINE _row / order COMPUTED NOPRINT ;
   COMPUTE _row;
      nobs+1;
      _row = nobs;
      IF (MOD( _row,2 )=0) THEN
         CALL DEFINE( _ROW_,'STYLE',"STYLE={BACKGROUND=graydd}" );
   ENDCOMP;
%MEND greenbar;


%macro pdfbeg(rules=all,frame=box);
    %utlnopts;
    options orientation=landscape validvarname=v7;
    ods listing close;
    ods pdf close;
    ods path work.templat(update) sasuser.templat(update) sashelp.tmplmst(read);
    %utlfkil(&wevoutpdf..pdf);
    ods noptitle;
    ods escapechar='^';
    ods listing close;
    ods graphics on / width=10in  height=7in ;
    ods pdf file="&wevoutpdf"
    style=utl_ymrlan100 notoc /* bookmarkgen=on bookmarklist=show */;
%mend pdfbeg;

%macro codebegin;
  options orientation=landscape lrecl=384;
  data _null_;
  length lyn $384;
   input;
   lyn=strip(_infile_);
   file print;
   put lyn "^{newline}" @;
   call execute(_infile_);
%mend codebegin;


%macro pdfend;
   ods graphics off;
   ods pdf close;
   ods listing;
   options ls=171 ps=66;
   %utlopts;
%mend pdfend;

%MACRO UTLOPTS
         / des = "Turn all debugging options off forgiving options";

OPTIONS

   OBS=MAX
   FIRSTOBS=1
   lrecl=384
   NOFMTERR      /* DO NOT FAIL ON MISSING FORMATS                              */
   SOURCE      /* turn sas source statements on                               */
   SOURCe2     /* turn sas source statements on                               */
   MACROGEN    /* turn  MACROGENERATON ON                                     */
   SYMBOLGEN   /* turn  SYMBOLGENERATION ON                                   */
   NOTES       /* turn  NOTES ON                                              */
   NOOVP       /* never overstike                                             */
   CMDMAC      /* turn  CMDMAC command macros on                              */
   /* ERRORS=2    turn  ERRORS=2  max of two errors                           */
   MLOGIC      /* turn  MLOGIC    macro logic                                 */
   MPRINT      /* turn  MPRINT    macro statements                            */
   MRECALL     /* turn  MRECALL   always recall                               */
   MERROR      /* turn  MERROR    show macro errors                           */
   NOCENTER    /* turn  NOCENTER  I do not like centering                     */
   DETAILS     /* turn  DETAILS   show details in dir window                  */
   SERROR      /* turn  SERROR    show unresolved macro refs                  */
   NONUMBER    /* turn  NONUMBER  do not number pages                         */
   FULLSTIMER  /*   turn  FULLSTIMER  give me all space/time stats            */
   NODATE      /* turn  NODATE      suppress date                             */
   /*DSOPTIONS=NOTE2ERR                                                                              */
   /*ERRORCHECK=STRICT /*  syntax-check mode when an error occurs in a LIBNAME or FILENAME statement */
   DKRICOND=WARN      /*  variable is missing from input data during a DROP=, KEEP=, or RENAME=     */
   DKROCOND=WARN      /*  variable is missing from output data during a DROP=, KEEP=, or RENAME=     */
   /* NO$SYNTAXCHECK  be careful with this one */
 ;

run;quit;

%MEND UTLOPTS;
%macro utlnopts(note2err=nonote2err,nonotes=nonotes)
    / des = "Turn  debugging options off";

OPTIONS
     FIRSTOBS=1
     NONUMBER
     MLOGICNEST
   /*  MCOMPILENOTE */
     MPRINTNEST
     lrecl=384
     MAUTOLOCDISPLAY
     NOFMTERR     /* turn  Format Error off                           */
     NOMACROGEN   /* turn  MACROGENERATON off                         */
     NOSYMBOLGEN  /* turn  SYMBOLGENERATION off                       */
     &NONOTES     /* turn  NOTES off                                  */
     NOOVP        /* never overstike                                  */
     NOCMDMAC     /* turn  CMDMAC command macros on                   */
     NOSOURCE    /* turn  source off * are you sure?                 */
     NOSOURCE2    /* turn  SOURCE2   show gererated source off        */
     NOMLOGIC     /* turn  MLOGIC    macro logic off                  */
     NOMPRINT     /* turn  MPRINT    macro statements off             */
     NOCENTER     /* turn  NOCENTER  I do not like centering          */
     NOMTRACE     /* turn  MTRACE    macro tracing                    */
     NOSERROR     /* turn  SERROR    show unresolved macro refs       */
     NOMERROR     /* turn  MERROR    show macro errors                */
     OBS=MAX      /* turn  max obs on                                 */
     NOFULLSTIMER /* turn  FULLSTIMER  give me all space/time stats   */
     NODATE       /* turn  NODATE      suppress date                  */
     DSOPTIONS=&NOTE2ERR
     ERRORCHECK=STRICT /*  syntax-check mode when an error occurs in a LIBNAME or FILENAME statement */
     DKRICOND=ERROR    /*  variable is missing from input data during a DROP=, KEEP=, or RENAME=     */

     /* NO$SYNTAXCHECK  be careful with this one */
;

RUN;quit;

%MEND UTLNOPTS;

*                                     _       _
 ___ _   _ _ __ ___  _ __ _   _    __| | __ _| |_ __ _
/ __| | | | '_ ` _ \| '__| | | |  / _` |/ _` | __/ _` |
\__ \ |_| | | | | | | |  | |_| | | (_| | (_| | || (_| |
|___/\__,_|_| |_| |_|_|   \__, |  \__,_|\__,_|\__\__,_|
                          |___/
 _        _           _       _
| |_ __ _| |__     __| | __ _| |_ __ _
| __/ _` | '_ \   / _` |/ _` | __/ _` |
| || (_| | |_) | | (_| | (_| | || (_| |
 \__\__,_|_.__/   \__,_|\__,_|\__\__,_|

;

%macro phy_100Cms(yr);

  DATA &pgm._npiTab;
      LENGTH
            npi                                 $10
            nppes_provider_last_org_name        $70
            nppes_provider_first_name           $20
            nppes_provider_mi                   $1
            nppes_credentials                   $20
            nppes_provider_gender               $1
            nppes_entity_code                   $1
            nppes_provider_street1              $55
            nppes_provider_street2              $55
            nppes_provider_city                 $40
            nppes_provider_zip                  $20
            nppes_provider_state                $2
            nppes_provider_country              $2
            provider_type                       $43
            medicare_participation_indicator    $1
        number_of_hcpcs                         8
            total_services                      8
            total_unique_benes                  8
            total_submitted_chrg_amt            8
            total_medicare_allowed_amt          8
            total_medicare_payment_amt          8
            total_medicare_stnd_amt             8
        drug_suppress_indicator                 $1
            number_of_drug_hcpcs                8
            total_drug_services                 8
            total_drug_unique_benes             8
        total_drug_submitted_chrg_amt           8
            total_drug_medicare_allowed_amt     8
            total_drug_medicare_payment_amt     8
        total_drug_medicare_stnd_amt            8
            med_suppress_indicator              $1
            number_of_med_hcpcs                 8
            total_med_services                  8
            total_med_unique_benes              8
            total_med_submitted_chrg_amt        8
            total_med_medicare_allowed_amt      8
            total_med_medicare_payment_amt      8
            total_med_medicare_stnd_amt         8
            beneficiary_average_age             8
            beneficiary_age_less_65_count       8
            beneficiary_age_65_74_count         8
            beneficiary_age_75_84_count         8
            beneficiary_age_greater_84_count    8
            beneficiary_female_count            8
            beneficiary_male_count              8
            beneficiary_race_white_count        8
            beneficiary_race_black_count        8
            beneficiary_race_api_count          8
            beneficiary_race_hispanic_count     8
            beneficiary_race_natind_count       8
            beneficiary_race_other_count        8
            beneficiary_nondual_count           8
            beneficiary_dual_count              8
            beneficiary_cc_afib_percent         8
            beneficiary_cc_alzrdsd_percent      8
            beneficiary_cc_asthma_percent       8
            beneficiary_cc_cancer_percent       8
            beneficiary_cc_chf_percent          8
            beneficiary_cc_ckd_percent          8
            beneficiary_cc_copd_percent         8
            beneficiary_cc_depr_percent         8
            beneficiary_cc_diab_percent         8
            beneficiary_cc_hyperl_percent       8
            beneficiary_cc_hypert_percent       8
            beneficiary_cc_ihd_percent          8
            beneficiary_cc_ost_percent          8
            beneficiary_cc_raoa_percent         8
            beneficiary_cc_schiot_percent       8
            beneficiary_cc_strk_percent         8
            beneficiary_average_risk_score      8;

      INFILE "d:\phy\txt\Medicare_Physician_and_Other_Supplier_NPI_Aggregate_CY&YR..txt"

            lrecl=32767
            dlm='09'x
            pad missover
            firstobs = 2
            dsd;

      INPUT
            npi
            nppes_provider_last_org_name
            nppes_provider_first_name
            nppes_provider_mi
            nppes_credentials
            nppes_provider_gender
            nppes_entity_code
            nppes_provider_street1
            nppes_provider_street2
            nppes_provider_city
            nppes_provider_zip
            nppes_provider_state
            nppes_provider_country
            provider_type
            medicare_participation_indicator
            number_of_hcpcs
            total_services
            total_unique_benes
            total_submitted_chrg_amt
            total_medicare_allowed_amt
            total_medicare_payment_amt
            total_medicare_stnd_amt
            drug_suppress_indicator
            number_of_drug_hcpcs
            total_drug_services
            total_drug_unique_benes
            total_drug_submitted_chrg_amt
            total_drug_medicare_allowed_amt
            total_drug_medicare_payment_amt
            total_drug_medicare_stnd_amt
            med_suppress_indicator
            number_of_med_hcpcs
            total_med_services
            total_med_unique_benes
            total_med_submitted_chrg_amt
            total_med_medicare_allowed_amt
            total_med_medicare_payment_amt
            total_med_medicare_stnd_amt
            beneficiary_average_age
            beneficiary_age_less_65_count
            beneficiary_age_65_74_count
            beneficiary_age_75_84_count
            beneficiary_age_greater_84_count
            beneficiary_female_count
            beneficiary_male_count
            beneficiary_race_white_count
            beneficiary_race_black_count
            beneficiary_race_api_count
            beneficiary_race_hispanic_count
            beneficiary_race_natind_count
            beneficiary_race_other_count
            beneficiary_nondual_count
            beneficiary_dual_count
            beneficiary_cc_afib_percent
            beneficiary_cc_alzrdsd_percent
            beneficiary_cc_asthma_percent
            beneficiary_cc_cancer_percent
            beneficiary_cc_chf_percent
            beneficiary_cc_ckd_percent
            beneficiary_cc_copd_percent
            beneficiary_cc_depr_percent
            beneficiary_cc_diab_percent
            beneficiary_cc_hyperl_percent
            beneficiary_cc_hypert_percent
            beneficiary_cc_ihd_percent
            beneficiary_cc_ost_percent
            beneficiary_cc_raoa_percent
            beneficiary_cc_schiot_percent
            beneficiary_cc_strk_percent
            beneficiary_average_risk_score
            ;

      LABEL
            npi                                  ="National Provider Identifier"
            nppes_provider_last_org_name         ="Last Name/Organization Name of the Provider"
            nppes_provider_first_name            ="First Name of the Provider"
            nppes_provider_mi                    ="Middle Initial of the Provider"
            nppes_credentials                    ="Credentials of the Provider"
            nppes_provider_gender                ="Gender of the Provider"
            nppes_entity_code                    ="Entity Type of the Provider"
            nppes_provider_street1               ="Street Address 1 of the Provider"
            nppes_provider_street2               ="Street Address 2 of the Provider"
            nppes_provider_city                  ="City of the Provider"
            nppes_provider_zip                   ="Zip Code of the Provider"
            nppes_provider_state                 ="State Code of the Provider"
            nppes_provider_country               ="Country Code of the Provider"
            provider_type                        ="Provider Type of the Provider"
            medicare_participation_indicator     ="Medicare Participation Indicator"
            number_of_hcpcs                      ="Number of HCPCS"
            total_services                       ="Number of Services"
            total_unique_benes                   ="Number of Medicare Beneficiaries"
            total_submitted_chrg_amt             ="Total Submitted Charge Amount"
            total_medicare_allowed_amt           ="Total Medicare Allowed Amount"
            total_medicare_payment_amt           ="Total Medicare Payment Amount"
            total_medicare_stnd_amt              ="Total Medicare Standardized Payment Amount"
            drug_suppress_indicator              ="Drug Suppress Indicator"
            number_of_drug_hcpcs                 ="Number of HCPCS Associated With Drug Services"
            total_drug_services                  ="Number of Drug Services"
            total_drug_unique_benes              ="Number of Medicare Beneficiaries With Drug Services"
            total_drug_submitted_chrg_amt        ="Total Drug Submitted Charge Amount"
            total_drug_medicare_allowed_amt      ="Total Drug Medicare Allowed Amount"
            total_drug_medicare_payment_amt      ="Total Drug Medicare Payment Amount"
            total_drug_medicare_stnd_amt         ="Total Drug Medicare Standardized Payment Amount"
            med_suppress_indicator               ="Medical Suppress Indicator"
            number_of_med_hcpcs                  ="Number of HCPCS Associated With Medical Services"
            total_med_services                   ="Number of Medical Services"
            total_med_unique_benes               ="Number of Medicare Beneficiaries With Medical Services"
            total_med_submitted_chrg_amt         ="Total Medical Submitted Charge Amount"
            total_med_medicare_allowed_amt       ="Total Medical Medicare Allowed Amount"
            total_med_medicare_payment_amt       ="Total Medical Medicare Payment Amount"
            total_med_medicare_stnd_amt          ="Total Medical Medicare Standardized Payment Amount"
            beneficiary_average_age              ="Average Age of Beneficiaries"
            beneficiary_age_less_65_count        ="Number of Beneficiaries Age Less 65"
            beneficiary_age_65_74_count          ="Number of Beneficiaries Age 65 to 74"
            beneficiary_age_75_84_count          ="Number of Beneficiaries Age 75 to 84"
            beneficiary_age_greater_84_count     ="Number of Beneficiaries Age Greater 84"
            beneficiary_female_count             ="Number of Female Beneficiaries"
            beneficiary_male_count               ="Number of Male Beneficiaries"
            beneficiary_race_white_count         ="Number of Non-Hispanic White Beneficiaries"
            beneficiary_race_black_count         ="Number of Black or African American Beneficiaries"
            beneficiary_race_api_count           ="Number of Asian Pacific Islander Beneficiaries"
            beneficiary_race_hispanic_count      ="Number of Hispanic Beneficiaries"
            beneficiary_race_natind_count        ="Number of American Indian/Alaska Native Beneficiaries"
            beneficiary_race_other_count         ="Number of Beneficiaries With Race Not Elsewhere Classified"
            beneficiary_nondual_count            ="Number of Beneficiaries With Medicare Only Entitlement"
            beneficiary_dual_count               ="Number of Beneficiaries With Medicare & Medicaid Entitlement"
            beneficiary_cc_afib_percent          ="Percent (%) of Beneficiaries Identified With Atrial Fibrillation"
            beneficiary_cc_alzrdsd_percent       ="Percent (%) of Beneficiaries Identified With Alzheimer’s Disease or Dementia"
            beneficiary_cc_asthma_percent        ="Percent (%) of Beneficiaries Identified With Asthma"
            beneficiary_cc_cancer_percent        ="Percent (%) of Beneficiaries Identified With Cancer"
            beneficiary_cc_chf_percent           ="Percent (%) of Beneficiaries Identified With Heart Failure"
            beneficiary_cc_ckd_percent           ="Percent (%) of Beneficiaries Identified With Chronic Kidney Disease"
            beneficiary_cc_copd_percent          ="Percent (%) of Beneficiaries Identified With Chronic Obstructive Pulmonary Disease"
            beneficiary_cc_depr_percent          ="Percent (%) of Beneficiaries Identified With Depression"
            beneficiary_cc_diab_percent          ="Percent (%) of Beneficiaries Identified With Diabetes"
            beneficiary_cc_hyperl_percent        ="Percent (%) of Beneficiaries Identified With Hyperlipidemia"
            beneficiary_cc_hypert_percent        ="Percent (%) of Beneficiaries Identified With Hypertension"
            beneficiary_cc_ihd_percent           ="Percent (%) of Beneficiaries Identified With Ischemic Heart Disease"
            beneficiary_cc_ost_percent           ="Percent (%) of Beneficiaries Identified With Osteoporosis"
            beneficiary_cc_raoa_percent          ="Percent (%) of Beneficiaries Identified With Rheumatoid Arthritis / Osteoarthritis"
            beneficiary_cc_schiot_percent        ="Percent (%) of Beneficiaries Identified With Schizophrenia / Other Psychotic Disorders"
            beneficiary_cc_strk_percent          ="Percent (%) of Beneficiaries Identified With Stroke"
            Beneficiary_Average_Risk_Score       ="Average HCC Risk Score of Beneficiaries"
;
run;quit;

%utl_optlen(inp=&pgm._npiTab,out=phy.&pgm._&yr.TabNpiSum);

%mend phy_100Cms;

%phy_100Cms(2015);
%phy_100Cms(2014);

options obs=max;
* combine 2014 and 2015 tab datasets;
proc sql;
  create
     table phy.&pgm._TabNpiSum as
  select
     '4' as fro label="Summary data Year 2012-2015"
    ,*
  from
     phy.&pgm._2014TabNpiSum
  union
     corr
  select
     '5' as fro
     ,*
  from
     phy.&pgm._2015TabNpiSum
;quit;


* Table PHY.PHY_100CMS_TABNPISUM created, with 2006119 rows and 70 columns;

*     _           _       _
__  _| |___    __| | __ _| |_ __ _
\ \/ / / __|  / _` |/ _` | __/ _` |
 >  <| \__ \ | (_| | (_| | || (_| |
/_/\_\_|___/  \__,_|\__,_|\__\__,_|

;

/* suggest you run these in separate SAS sessions simultaneosly
   These take a very long time
   I have guessing rows to maximum

* 1 hr to run;
libname xel "d:/phy/xls/Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2013.xlsx";
data phy.&pgm._2013XlsNpiSum;
  set xel.'data$'n;;
run;quit;
libname xel clear;


* 1 hr to run;
libname xel "d:/phy/xls/Medicare-Physician-and-Other-Supplier-NPI-Aggregate-CY2012.xlsx";
data phy.&pgm._2012XlsNpiSum;
  set xel.'data$'n;;
run;quit;
libname xel clear;
*/

/* fix dif types problem by removing variable with conflicting types;
   I have guessing rows to maximum

  48    NUMBER_OF_BENEFICIARIES_WITH_RAC    Num       4
  ERROR: Column 48 from the first contributor of UNION is not the same type as its counterpart from the second.
  2012 has a comma in the number and 2013 does not;
*/

* combine 2012 and 2013;
proc sql;
  create
    table phy.&pgm._XlsNpiSum as
  select
     '2' as fro label="Summary data Year 2012-2015"
    ,*
  from
    phy.&pgm._2012xlsNpiSum(drop=number_of_beneficiaries_with_rac) /* 69 variables */
  union
    corr
  select
    '3' as fro
   ,*
  from
    phy.&pgm._2013xlsNpiSum(drop=number_of_beneficiaries_with_rac) /* 69 variables */
;quit;

proc datasets lib=phy;
  modify &pgm._XlsNpiSum;
   label npi="National Provider Identifier";
run;quit;

/*
NOTE: PHY.PHY_100CMS_XLSNPISUM created, with 1881621 rows and 67 columns.
*/
*     _        ___     _        _
__  _| |___   ( _ )   | |_ __ _| |__
\ \/ / / __|  / _ \/\ | __/ _` | '_ \
 >  <| \__ \ | (_>  < | || (_| | |_) |
/_/\_\_|___/  \___/\/  \__\__,_|_.__/

;
* now we need to try to put the xls files with the tab files;
* output the tab file variable names and labels;

* we will use the labels in the tab and xls files to rename
  the xls files so we can combine the xls and athe tap files;

proc sql;
  create
    table &pgm._tabNamLbl as
  select
    monotonic() as tabKey
   ,name
   ,case
     when (index(label,'of the Provider'))>0 then substr(label,1,length(label)-16)
     else label
    end as label
  from
    sashelp.vcolumn
  where
    %upcase("&pgm._TabNpiSum") = memname and
    libname = "PHY"
;quit;

* output the xls file variable names and labels;
proc sql;
  create
    table &pgm._xlsNamLblPre as
  select
    monotonic() as xlsKey
   ,name
   ,case
     when (label eqt 'NPPES Provider') then substr(label,16)
     else label
    end as label
  from
    sashelp.vcolumn
  where
    %upcase("&pgm._XlsNpiSum") = memname and
    libname = "PHY" and
    label ne ""
;quit;

* match some of the missing matches;
* manual fixes to the xls labels because these do not match the labels on the tab files;
data &pgm._xlsNamLbl;
  set &pgm._xlsNamLblPre;
  select (xlsKey);
    when ( 3) label='Last Name/Organization Name                           ';
    when ( 6) label='Credentials                                           ';
    when ( 8) label='Entity Type                                           ';
    when (13) label='State Code                                            ';
    when (14) label='Country Code                                          ';
    when (19) label='Number of Medicare Beneficiaries                      ';
    when (20) label='Total Submitted Charge Amount                         ';
    when (27) label='Total Drug Submitted Charge Amount                    ';
    when (34) label='Total Medical Submitted Charge Amount                 ';
    when (26) label='Number of Medicare Beneficiaries With Drug Services   ';
    when (33) label='Number of Medicare Beneficiaries With Medical Services';
    otherwise;
  end;
run;quit;

* build the rename statement for xls dataset;
* fuzzy but tight match using compged;
proc sql;
  create
    table &pgm._xpoNam as
  select
    tab.tabKey
   ,xls.xlsKey
   ,xls.name as xlsNam
   ,tab.name as tabNam
   ,xls.label as xlsLabel
   ,tab.label as tabLabel
  from
    &pgm._xlsNamLbl as xls full outer join &pgm._tabNamLbl as tab
  on
    compged(substr(upcase(strip(xls.label)),1,64),substr(upcase(strip(tab.label)),1,64)) < 10
  where
    xls.name not in ('F68','F69')
;quit;

/*
options ls=255 ps=500;
proc print data=&pgm._xpoNam width=min;
var xlsKey tabKey xlsLabel tabLabel;
run;quit;

proc print data=&pgm._xpoNam width=min;
var xlsNam tabNam;
run;quit;
*/

* rename the variables in the xls files so variable names match;
data _null_;

  if _n_=0 then do;
    %let rc=%sysfunc(dosubl('
     proc sql;
       select
          cats(xlsNam,'=',tabNam)
       into
          :_ren separated by " "
       from
          &pgm._xpoNam
       where
          not ( xlsNam eq " " or xlsNam = tabNam)
     ;quit;
    '));
  end;

  rc=dosubl('
     proc datasets li=phy;
       modify &pgm._XlsNpiSum;
         rename
           &_ren
         ;
     run;quit;
  ');
run;quit;

* put tab and xls years together;

* __ _             _   _        _                    _
 / _(_)_ __   __ _| | | |_ __ _| |__      _    __  _| |___
| |_| | '_ \ / _` | | | __/ _` | '_ \   _| |_  \ \/ / / __|
|  _| | | | | (_| | | | || (_| | |_) | |_   _|  >  <| \__ \
|_| |_|_| |_|\__,_|_|  \__\__,_|_.__/    |_|   /_/\_\_|___/

;

data phy.&pgm._npisum(rename=fro=year
  label="all summary data 2012-2013 xls files combined with 2014-2015 tab file");
  retain key . fro '  '  profession provider_type_cd provider_type;
  set
    phy.&pgm._xlsnpisum
    phy.&pgm._tabnpisum
  ;
  key=_n_;

  provider_type_cd=put(provider_type,$&pgm._ptype2code.);

  profession= put(compress(NPPES_CREDENTIALS,'.,'),$&pgm._cred2prof.);

  If strip(NPPES_CREDENTIALS) =: 'NURSE PRACTITIONER'   then profession='NP';
  If strip(NPPES_CREDENTIALS) =: 'PHYSICIAN ASSISTANT'  then profession='PA';
  If strip(NPPES_CREDENTIALS) =: 'PHYSICIANS ASSISTANT' then profession='PA';
  If strip(NPPES_CREDENTIALS) =: 'MEDICAL DOCTOR'       then profession='MD';
  If strip(NPPES_CREDENTIALS) =: 'PHYSICAL THERAPIST'   then profession='PT';

  if compress(NPPES_CREDENTIALS,'.,') =: 'DC '  then profession='DC';
  if compress(NPPES_CREDENTIALS,'.,') =: 'MD'  then profession='MD';
  if compress(NPPES_CREDENTIALS,'.,') =: 'M D'  then profession='MD';
  if compress(NPPES_CREDENTIALS,'.,') =: 'DO ' then profession='DO';
  if compress(NPPES_CREDENTIALS,'.,') =: 'OD ' then profession='OD';
  if compress(NPPES_CREDENTIALS,'.,') =: 'O D ' then profession='OD';
  if compress(NPPES_CREDENTIALS,'.,') =: 'D O ' then profession='DO';
  if compress(NPPES_CREDENTIALS,'.,') =: 'P A ' then profession='PA';
  if compress(NPPES_CREDENTIALS,'.,') =: 'PA ' then profession='PA';
  if compress(NPPES_CREDENTIALS,'.,') =: 'PA-' then profession='PA';
  if compress(NPPES_CREDENTIALS,'.,') =: 'RN ' then profession='NURSE';
  if compress(NPPES_CREDENTIALS,'.,') =: 'RN ' then profession='NURSE';
  if compress(NPPES_CREDENTIALS,'.,') =: 'RN/NP' then profession='NP';

run;quit;
*          _ _ _      __            _      ___
 ___ _ __ | (_) |_   / _| __ _  ___| |_   ( _ )
/ __| '_ \| | | __| | |_ / _` |/ __| __|  / _ \/\
\__ \ |_) | | | |_  |  _| (_| | (__| |_  | (_>  <
|___/ .__/|_|_|\__| |_|  \__,_|\___|\__|  \___/\/
    |_|
     _ _                          _
  __| (_)_ __ ___   ___ _ __  ___(_) ___  _ __
 / _` | | '_ ` _ \ / _ \ '_ \/ __| |/ _ \| '_ \
| (_| | | | | | | |  __/ | | \__ \ | (_) | | | |
 \__,_|_|_| |_| |_|\___|_| |_|___/_|\___/|_| |_|

;
* separate long address variables into phy.&pgm._sumAddress;
* making all varoable integers save space;

data

   phy.&pgm._sumAddress
     (keep=
        KEY
        NPI
        YEAR
        PROFESSION
        PROVIDER_TYPE_CD
        PROVIDER_TYPE
        DRUG_SUPPRESS_INDICATOR
        NPPES_PROVIDER_GENDER
        NPPES_PROVIDER_LAST_ORG_NAME
        NPPES_PROVIDER_FIRST_NAME
        NPPES_PROVIDER_MI
        NPPES_CREDENTIALS
        NPPES_ENTITY_CODE
        NPPES_PROVIDER_STREET1
        NPPES_PROVIDER_STREET2
        NPPES_PROVIDER_CITY
        NPPES_PROVIDER_STATE
        NPPES_PROVIDER_COUNTRY
        label="Summary data 2012-2015 final address dimension table"
        compress=char
     )

   phy.&pgm._sumFacts
      (keep=
        KEY
        NPI
        YEAR
        PROFESSION
        PROVIDER_TYPE_CD
        NPPES_PROVIDER_ZIP
        MEDICARE_PARTICIPATION_INDICATOR
        NPPES_PROVIDER_GENDER
        BENEFICIARY_AVERAGE_AGE
        BENEFICIARY_FEMALE_COUNT
        BENEFICIARY_MALE_COUNT
        BENEFICIARY_RACE_WHITE_COUNT
        BENEFICIARY_RACE_BLACK_COUNT
        BENEFICIARY_RACE_HISPANIC_COUNT
        BENEFICIARY_NONDUAL_COUNT
        BENEFICIARY_DUAL_COUNT
        NUMBER_OF_HCPCS
        TOTAL_SERVICES
        TOTAL_UNIQUE_BENES
        TOTAL_MEDICARE_PAYMENT_AMT
        TOTAL_DRUG_MEDICARE_PAYMENT_AMT
        TOTAL_MED_MEDICARE_PAYMENT_AMT
        NUMBER_OF_DRUG_HCPCS
        TOTAL_DRUG_SERVICES
        TOTAL_DRUG_UNIQUE_BENES
        NUMBER_OF_MED_HCPCS
        TOTAL_MED_SERVICES
        TOTAL_MED_UNIQUE_BENES
        BENEFICIARY_AGE_LESS_65_COUNT
        BENEFICIARY_AGE_65_74_COUNT
        BENEFICIARY_AGE_75_84_COUNT
        BENEFICIARY_AGE_GREATER_84_COUNT
        BENEFICIARY_RACE_API_COUNT
        BENEFICIARY_RACE_NATIND_COUNT
        BENEFICIARY_CC_ALZRDSD_PERCENT
        BENEFICIARY_CC_ASTHMA_PERCENT
        BENEFICIARY_CC_AFIB_PERCENT
        BENEFICIARY_CC_CANCER_PERCENT
        BENEFICIARY_CC_CKD_PERCENT
        BENEFICIARY_CC_COPD_PERCENT
        BENEFICIARY_CC_DEPR_PERCENT
        BENEFICIARY_CC_DIAB_PERCENT
        BENEFICIARY_CC_CHF_PERCENT
        BENEFICIARY_CC_HYPERL_PERCENT
        BENEFICIARY_CC_HYPERT_PERCENT
        BENEFICIARY_CC_IHD_PERCENT
        BENEFICIARY_CC_OST_PERCENT
        BENEFICIARY_CC_RAOA_PERCENT
        BENEFICIARY_CC_SCHIOT_PERCENT
        BENEFICIARY_CC_STRK_PERCENT
        TOTAL_DRUG_SUBMITTED_CHRG_AMT
        TOTAL_DRUG_MEDICARE_ALLOWED_AMT
        TOTAL_SUBMITTED_CHRG_AMT
        TOTAL_MEDICARE_ALLOWED_AMT
        TOTAL_MED_SUBMITTED_CHRG_AMT
        TOTAL_MED_MEDICARE_ALLOWED_AMT
        TOTAL_MEDICARE_STND_AMT
        TOTAL_DRUG_MEDICARE_STND_AMT
        TOTAL_MED_MEDICARE_STND_AMT
        BENEFICIARY_RACE_OTHER_COUNT
        BENEFICIARY_AVERAGE_RISK_SCORE
        label="Summary data 2012-2015 final fact table"
       );

    retain
        KEY
        NPI
        YEAR
        PROFESSION
        PROVIDER_TYPE_CD
        PROVIDER_TYPE
        NPPES_PROVIDER_LAST_ORG_NAME
        NPPES_PROVIDER_FIRST_NAME
        NPPES_PROVIDER_MI
        NPPES_CREDENTIALS
        NPPES_ENTITY_CODE
        NPPES_PROVIDER_STREET1
        NPPES_PROVIDER_STREET2
        NPPES_PROVIDER_CITY
        NPPES_PROVIDER_STATE
        NPPES_PROVIDER_COUNTRY
        NPPES_PROVIDER_ZIP
        MEDICARE_PARTICIPATION_INDICATOR
        DRUG_SUPPRESS_INDICATOR
        NPPES_PROVIDER_GENDER
        BENEFICIARY_AVERAGE_AGE
        BENEFICIARY_FEMALE_COUNT
        BENEFICIARY_MALE_COUNT
        BENEFICIARY_RACE_WHITE_COUNT
        BENEFICIARY_RACE_BLACK_COUNT
        BENEFICIARY_RACE_HISPANIC_COUNT
        BENEFICIARY_NONDUAL_COUNT
        BENEFICIARY_DUAL_COUNT
        NUMBER_OF_HCPCS
        TOTAL_SERVICES
        TOTAL_UNIQUE_BENES
        TOTAL_MEDICARE_PAYMENT_AMT
        TOTAL_DRUG_MEDICARE_PAYMENT_AMT
        TOTAL_MED_MEDICARE_PAYMENT_AMT
        NUMBER_OF_DRUG_HCPCS
        TOTAL_DRUG_SERVICES
        TOTAL_DRUG_UNIQUE_BENES
        NUMBER_OF_MED_HCPCS
        TOTAL_MED_SERVICES
        TOTAL_MED_UNIQUE_BENES
        BENEFICIARY_AGE_LESS_65_COUNT
        BENEFICIARY_AGE_65_74_COUNT
        BENEFICIARY_AGE_75_84_COUNT
        BENEFICIARY_AGE_GREATER_84_COUNT
        BENEFICIARY_RACE_API_COUNT
        BENEFICIARY_RACE_NATIND_COUNT
        BENEFICIARY_CC_ALZRDSD_PERCENT
        BENEFICIARY_CC_ASTHMA_PERCENT
        BENEFICIARY_CC_AFIB_PERCENT
        BENEFICIARY_CC_CANCER_PERCENT
        BENEFICIARY_CC_CKD_PERCENT
        BENEFICIARY_CC_COPD_PERCENT
        BENEFICIARY_CC_DEPR_PERCENT
        BENEFICIARY_CC_DIAB_PERCENT
        BENEFICIARY_CC_CHF_PERCENT
        BENEFICIARY_CC_HYPERL_PERCENT
        BENEFICIARY_CC_HYPERT_PERCENT
        BENEFICIARY_CC_IHD_PERCENT
        BENEFICIARY_CC_OST_PERCENT
        BENEFICIARY_CC_RAOA_PERCENT
        BENEFICIARY_CC_SCHIOT_PERCENT
        BENEFICIARY_CC_STRK_PERCENT
        TOTAL_DRUG_SUBMITTED_CHRG_AMT
        TOTAL_DRUG_MEDICARE_ALLOWED_AMT
        TOTAL_SUBMITTED_CHRG_AMT
        TOTAL_MEDICARE_ALLOWED_AMT
        TOTAL_MED_SUBMITTED_CHRG_AMT
        TOTAL_MED_MEDICARE_ALLOWED_AMT
        TOTAL_MEDICARE_STND_AMT
        TOTAL_DRUG_MEDICARE_STND_AMT
        TOTAL_MED_MEDICARE_STND_AMT
        BENEFICIARY_RACE_OTHER_COUNT
        BENEFICIARY_AVERAGE_RISK_SCORE
      ;

      set phy.&pgm._npisum(
         where=(nppes_provider_country='US' and profession in ( 'MD' 'NP' 'PA' 'DO' 'NURSE' 'DC' 'OD' )));

      array nums[*] _numeric_;

      do _i_=1 to dim(nums);
         nums[_i_]=round(nums[_i_]);
      end;

run;quit;

*_               _     _                  _   _
| |__   ___  ___| |_  | | ___ _ __   __ _| |_| |__  ___
| '_ \ / _ \/ __| __| | |/ _ \ '_ \ / _` | __| '_ \/ __|
| |_) |  __/\__ \ |_  | |  __/ | | | (_| | |_| | | \__ \
|_.__/ \___||___/\__| |_|\___|_| |_|\__, |\__|_| |_|___/
                                    |___/
;


%utl_optlen(inp=phy.&pgm._sumAddress,out=phy.&pgm._sumAddress);
%utl_optlen(inp=phy.&pgm._sumFacts,out=phy.&pgm._sumFacts);


/*
proc sort data=phy.&pgm._sumFacts(keep=npi year) out=chk;
by npi year;
run;quit;
*/


* Fact file is only 600mb;

 -- CHARACTER --
NPI                              C10      1043573298  National Provider Identifier
YEAR                             C1       4           Summary data Year 2012-2015
PROFESSION                       C5       PA          PROFESSION
PROVIDER_TYPE_CD                 C2       69          PROVIDER_TYPE_CD
NPPES_PROVIDER_ZIP               C10      166681017   NPPES Provider Zip Code
MEDICARE_PARTICIPATION_INDICATOR C1       Y           Medicare Participation Indicator
DRUG_SUPPRESS_INDICATOR          C1                   Drug Suppress Indicator
NPPES_PROVIDER_GENDER            C1       F           NPPES Provider Gender

Note how short the numerics are now;

 -- NUMERIC --
KEY                              N5       1930337     KEY
BENEFICIARY_AVERAGE_AGE          N3       75          Average Age of Beneficiaries
BENEFICIARY_FEMALE_COUNT         N4       .           Number of Female Beneficiaries
BENEFICIARY_MALE_COUNT           N4       .           Number of Male Beneficiaries
BENEFICIARY_RACE_WHITE_COUNT     N4       11          Number of Non-Hispanic White Beneficiaries
BENEFICIARY_RACE_BLACK_COUNT     N4       0           Number of Black or African American Beneficiaries
BENEFICIARY_RACE_HISPANIC_COUNT  N3       0           Number of Hispanic Beneficiaries
BENEFICIARY_NONDUAL_COUNT        N4       .           Number of Beneficiaries With Medicare Only Entitlement
BENEFICIARY_DUAL_COUNT           N4       .           Number of Beneficiaries With Medicare & Medicaid Entitlement
NUMBER_OF_HCPCS                  N3       4           Number of HCPCS
TOTAL_SERVICES                   N5       12          Number of Services
TOTAL_UNIQUE_BENES               N4       11          Number of Unique Beneficiaries
TOTAL_MEDICARE_PAYMENT_AMT       N5       347         Total Medicare Payment Amount
TOTAL_DRUG_MEDICARE_PAYMENT_AMT  N5       0           Total Drug Medicare Payment Amount
TOTAL_MED_MEDICARE_PAYMENT_AMT   N5       347         Total Medical Medicare Payment Amount
NUMBER_OF_DRUG_HCPCS             N3       0           Number of HCPCS Associated With Drug Services
TOTAL_DRUG_SERVICES              N5       0           Number of Drug Services
TOTAL_DRUG_UNIQUE_BENES          N4       0           Number of Unique Beneficiaries With Drug Services
NUMBER_OF_MED_HCPCS              N3       4           Number of HCPCS Associated With Medical Services
TOTAL_MED_SERVICES               N5       12          Number of Medical Services
TOTAL_MED_UNIQUE_BENES           N4       11          Number of Unique Beneficiaries With Medical Services
BENEFICIARY_AGE_LESS_65_COUNT    N4       .           Number of Beneficiaries Age Less 65
BENEFICIARY_AGE_65_74_COUNT      N4       0           Number of Beneficiaries Age 65 to 74
BENEFICIARY_AGE_75_84_COUNT      N4       .           Number of Beneficiaries Age 75 to 84
BENEFICIARY_AGE_GREATER_84_COUNT N4       .           Number of Beneficiaries Age Greater 84
BENEFICIARY_RACE_API_COUNT       N3       0           Number of Asian Pacific Islander Beneficiaries
BENEFICIARY_RACE_NATIND_COUNT    N3       0           Number of American Indian/Alaska Native Beneficiaries
BENEFICIARY_CC_ALZRDSD_PERCENT   N3       .           Percent (%) of Beneficiaries Identified With Alzheimer’s Disease
BENEFICIARY_CC_ASTHMA_PERCENT    N3       0           Percent (%) of Beneficiaries Identified With Asthma
BENEFICIARY_CC_AFIB_PERCENT      N3       0           Percent (%) of Beneficiaries Identified With Atrial Fibrillation
BENEFICIARY_CC_CANCER_PERCENT    N3       .           Percent (%) of Beneficiaries Identified With Cancer
BENEFICIARY_CC_CKD_PERCENT       N3       .           Percent (%) of Beneficiaries Identified With Chronic Kidney Dise
BENEFICIARY_CC_COPD_PERCENT      N3       0           Percent (%) of Beneficiaries Identified With Chronic Obstructive
BENEFICIARY_CC_DEPR_PERCENT      N3       .           Percent (%) of Beneficiaries Identified With Depression
BENEFICIARY_CC_DIAB_PERCENT      N3       .           Percent (%) of Beneficiaries Identified With Diabetes
BENEFICIARY_CC_CHF_PERCENT       N3       .           Percent (%) of Beneficiaries Identified With Heart Failure
BENEFICIARY_CC_HYPERL_PERCENT    N3       .           Percent (%) of Beneficiaries Identified With Hyperlipidemia
BENEFICIARY_CC_HYPERT_PERCENT    N3       .           Percent (%) of Beneficiaries Identified With Hypertension
BENEFICIARY_CC_IHD_PERCENT       N3       .           Percent (%) of Beneficiaries Identified With Ischemic Heart Dise
BENEFICIARY_CC_OST_PERCENT       N3       .           Percent (%) of Beneficiaries Identified With Osteoporosis
BENEFICIARY_CC_RAOA_PERCENT      N3       .           Percent (%) of Beneficiaries Identified With Rheumatoid Arthriti
BENEFICIARY_CC_SCHIOT_PERCENT    N3       0           Percent (%) of Beneficiaries Identified With Schizophrenia / Oth
BENEFICIARY_CC_STRK_PERCENT      N3       0           Percent (%) of Beneficiaries Identified With Stroke
TOTAL_DRUG_SUBMITTED_CHRG_AMT    N5       0           Total Drug Submitted Charges
TOTAL_DRUG_MEDICARE_ALLOWED_AMT  N5       0           Total Drug Medicare Allowed Amount
TOTAL_SUBMITTED_CHRG_AMT         N5       1390        Total Submitted Charges
TOTAL_MEDICARE_ALLOWED_AMT       N5       710         Total Medicare Allowed Amount
TOTAL_MED_SUBMITTED_CHRG_AMT     N5       1390        Total Medical Submitted Charges
TOTAL_MED_MEDICARE_ALLOWED_AMT   N5       710         Total Medical Medicare Allowed Amount
TOTAL_MEDICARE_STND_AMT          N5       481         Total Medicare Standardized Payment Amount
TOTAL_DRUG_MEDICARE_STND_AMT     N5       0           Total Drug Medicare Standardized Payment Amount
TOTAL_MED_MEDICARE_STND_AMT      N5       481         Total Medical Medicare Standardized Payment Amount
BENEFICIARY_RACE_OTHER_COUNT     N3       0           Number of Beneficiaries With Race Not Elsewhere Classified
BENEFICIARY_AVERAGE_RISK_SCORE   N3       1           Average HCC Risk Score of Beneficiaries


 95% cleaned up fuzzy
PROFESSION     Frequency     Percent     Frequency      Percent
----------------------------------------------------------------
MD              2079266       58.77       2079266        58.77
NP               212314        6.00       2291580        64.78
PA               201474        5.70       2493054        70.47
DO               191217        5.41       2684271        75.88
NURSE            173766        4.91       2858037        80.79
DC               137221        3.88       2995258        84.67
OD               109576        3.10       3104834        87.76
PT                79474        2.25       3184308        90.01
DPM               56701        1.60       3241009        91.61
PHD               38454        1.09       3279463        92.70
DPT               31396        0.89       3310859        93.59
LCSW              28985        0.82       3339844        94.41


beneficiary_female_count        Number of Female Beneficiaries"
beneficiary_male_count          Number of Male Beneficiaries"
beneficiary_race_white_count    Number of Non-Hispanic White Beneficiaries"
beneficiary_race_black_count    Number of Black or African American Beneficiaries"
beneficiary_race_api_count      Number of Asian Pacific Islander Beneficiaries"
beneficiary_race_hispanic_count Number of Hispanic Beneficiaries"
beneficiary_race_natind_count   Number of American Indian/Alaska Native Beneficiaries"
*/

*                        _
 _ __   __ _ _   _    __| |_ __ _   _  __ _ ___
| '_ \ / _` | | | |  / _` | '__| | | |/ _` / __|
| |_) | (_| | |_| | | (_| | |  | |_| | (_| \__ \
| .__/ \__,_|\__, |  \__,_|_|   \__,_|\__, |___/
|_|          |___/                    |___/
;

* target is asthma;

data  phy.&pgm._tajInp;

  set phy.&pgm._sumFacts (
     where=( edicare_participation_indicator = 'Y' and provider_type_cd='27' and profession in ('MD')));
  format _numeric_;

  provider_gender=0;
  if nppes_provider_gender ='F' then provider_gender=1;

  drug_pct_of_total = TOTAL_DRUG_UNIQUE_BENES/TOTAL_UNIQUE_BENES;
  if drug_pct_of_total >0;

  xpo_drug_pct_of_total =  arsin(sqrt(drug_pct_of_total));

  keep npi year provider_gender drug_pct_of_total xpo_drug_pct_of_total;

run;quit;

proc sort data=phy.&pgm._tajInp  out=&pgm._tajInp;
  by npi  provider_gender year;
run;quit;

proc transpose data=&pgm._tajInp out=phy.&pgm._tajXpo(drop=_name_ _label_) prefix=year_ ;
  by npi provider_gender;
  var xpo_drug_pct_of_total;
  id year;
run;quit;

* require data in all years and add time variables;
data phy.&pgm._tajMdl (where=(year_2>0 and year_3>0 and year_4>0 and year_5>0));
  retain t2 2 t3 3 t4 4 t5 5;
  set phy.&pgm._tajXpo;
run;quit;


options ls=171 ps=64;
%utlvdoc
    (
    libname        = phy                   /* libname of input dataset */
    ,data          = &pgm._tajMdl       /* name of input dataset */
    ,key           = npi          /* 0 or variable */
    ,ExtrmVal      = 20           /* display top and bottom 30 frequencies */
    ,UniPlot       = 1            /* 'true' enables ('false' disables) plot option on univariate output */
    ,UniVar        = 1            /* 'true' enables ('false' disables) plot option on univariate output */
    ,misspat       = 1            /* 0 or 1 missing patterns */
    ,chart         = 1            /* 0 or 1 line printer chart */
    ,taball        = 0            /* variable 0 */
    ,tabone        = 0  /* 0 or  variable vs all other variables          */
    ,mispop        = 1            /* 0 or 1  missing vs populated*/
    ,dupcol        = 1            /* 0 or 1  columns duplicated  */
    ,unqtwo        = year_2 year_3 year_4 year_5          /* 0 */
    ,vdocor        = 1            /* 0 or 1  correlation of numeric variables */
    ,oneone        = 1            /* 0 or 1  one to one - one to many - many to many */
    ,cramer        = 1            /* 0 or 1  association of character variables    */
    ,optlength     = 0
    ,maxmin        = 1
    ,unichr        = 1
    ,outlier       = 1
    ,printto       = d:\phy\vdo\&data..txt        /* file or output if output window */
    ,Cleanup       = 1           /* 0 or 1 delete intermediate datasets */
    );
options ls=171 ps=64;


options ls=171 ps=66;
proc traj data=phy.&pgm._tajMdl
       out = phy.&pgm._tajMdlDetail
   outplot = phy.&pgm._tajMdlPlot
   outstat = phy.&pgm._tajMdlStat ci95M;
  id npi;
  var year_2-year_5 ;
  indep t2-t5;
  order 2 2;
  max 1.5707964;
  model cnorm;
run;quit;

/*

proc

                       Maximum Likelihood Estimates
                       Model: Censored Normal (CNORM)

                                  Standard       T for H0:
Group   Parameter    Estimate        Error     Parameter=0   Prob > |T|

1       Intercept     0.32720      0.00345          94.825       0.0000
        Linear       -0.00325      0.00211          -1.536       0.1244
        Quadratic     0.00096      0.00030           3.213       0.0013

2       Intercept     0.68258      0.00312         218.712       0.0000
        Linear       -0.02707      0.00191         -14.154       0.0000
        Quadratic     0.00642      0.00027          23.686       0.0000

        Sigma         0.13738      0.00014         954.511       0.0000

        Group membership
1             (%)    45.06568      0.16282         276.778       0.0000
2             (%)    54.93432      0.16282         337.388       0.0000

BIC=194971.48 (N=472952)  BIC=194977.02 (N=118238)  AIC=195015.74  L=195023.74

*/

* plots;
options ls=64 ps=44;
proc plot data=phy.&pgm._tajMdlPlot;
format t 2.;
plot  (pred1 pred2)*t='*' / overlay haxis=5  to 1 by -1 ;
run;quit;
options ls=171 ps=66;

* transform back to original percents;
data phy.&pgm._xpoDetail;
  retain avg_pct xpo_avg_pct;
  set phy.&pgm._tajMdlDetail;

  year_2pct  = sin(year_2)**2;
  year_3pct  = sin(year_3)**2;
  year_4pct  = sin(year_4)**2;
  year_5pct  = sin(year_5)**2;

  avg_pct    =  mean(of  year_2pct
                     ,year_3pct
                     ,year_4pct
                     ,year_5pct);

  xpo_avg_pct=  mean(of  year_2
                            ,year_3
                            ,year_4
                            ,year_5);
run;quit;


data phy.&pgm._xpoPlot;

  set phy.&pgm._tajMdlPlot;

  pred1Xpo  = sin(pred1)**2;
  pred2Xpo  = sin(pred2)**2;
  predAXpo  = (pred1Xpo + pred2Xpo)/2;

run;quit;

options ls=64 ps=44;
proc plot data=phy.&pgm._xpoPlot;
format t 2.;
plot  (pred1xpo pred2xpo)*t='*' / overlay haxis=5  to 1 by -1 ;
run;quit;
options ls=171 ps=66;

*_                    _ _
| |__   __ _ ___  ___| (_)_ __   ___  __   ____ _ _ __ ___
| '_ \ / _` / __|/ _ \ | | '_ \ / _ \ \ \ / / _` | '__/ __|
| |_) | (_| \__ \  __/ | | | | |  __/  \ V / (_| | |  \__ \
|_.__/ \__,_|___/\___|_|_|_| |_|\___|   \_/ \__,_|_|  |___/

;


/*
inset (
" " ="March has the highest Incidence of asthma"
" " ="Oscillations in Aug-Dec are due to alternating 30-31 day months"
" " ="Similar lower response for less than 31 day months outside of March"
" " ="Similar higher response for 31 day months outside of March"
) / position=topright textattrs=( Size=15pt);


proc sql;
  create
    table phy.&pgm._facAll as
  select
    l.*
   ,r.*
  from
    phy.&pgm._xpoDetail as l, phy.&pgm._sumFacts as r
  where
    l.npi = r.npi
  order
    by group, npi, year
;quit;


proc transpose data=phy.&pgm._facAll out=phy.&pgm._facXpo;
  by group npi;
  id group year;
  var _numeric_;
run;quit;

proc sql;
  create
    table phy.&pgm._facAll as
  select
    l.group
   ,r.*
  from
    phy.&pgm._tajMdlDetail(keep=npi group) as l, phy.&pgm._sumFacts as r
  where
    l.npi = r.npi
;quit;


proc summary data=phy.&pgm._facAll;
class group;
var _numeric_;
output out=phy.&pgm._mdl median=;
run;quit;

data &pgm._addIds/view=&pgm._addIds;
  set phy.&pgm._mdl;
  if group=. then group=3;
run;quit;

proc transpose data=&pgm._addIds out=phy.&pgm._mdlMed;
  var _numeric_;
  id group;
run;quit;

* adjust number and total for rquency differences;
data phy.&pgm._mdlMedAdj;
  set phy.&pgm._mdlMed;
  if scan(_label_,' ') in ("Number","Total", " ") then _1=0.8373236359*_1;
run;quit;

*/

     
proc format;
   value taj
      1  ='AJT @Page @01 @Order @010 @Group - n (%)  @      Trajectory Means'
      2 = 'AJT @Page @01 @Order @010 @Group - n (%)  @      Trajectory Means'
   ;
   value obs
      1  ='OBS @Page @01 @Order @020 @Group - n (%)  @      Observations'
      2 = 'OBS @Page @01 @Order @020 @Group - n (%)  @      Observations'
   ;
   value sex
      0  ='SEX @Page @01 @Order @030 @Sex - n (%)  @      Male'
      1 = 'SEX @Page @01 @Order @040 @Sex - n (%)  @      Female'
   ;
   value srg
      1  ='SRG @Page @01 @Order @050 @Physician Practice - n (%)  @      Medical'
      0 = 'SRG @Page @01 @Order @060 @Physician Practice - n (%)  @      Other'
   ;
   value rgn
      1 = "RGN @Page @01 @Order @070 @Region - n (%) @      Northeast Region"
      2 = "RGN @Page @01 @Order @080 @Region - n (%) @      South Region"
      3 = "RGN @Page @01 @Order @090 @Region - n (%) @      Midwest Region"
      4 = "RGN @Page @01 @Order @100 @Region - n (%) @      West Region"
      5 = "RGN @Page @01 @Order @110 @Region - n (%) @      Other"
   ;
run;quit;

* mean of group1 and group2;
proc sql;
  select
     put(100*mean(pred1Xpo),6.2)
    ,put(100*mean(pred2Xpo),6.2)
    ,put(100*mean(predAXpo),6.2)
  into
     :group1 trimmed
    ,:group2 trimmed
    ,:groupa trimmed
  from
    phy.&pgm._xpoPlot
;quit;

proc sql;
  select
     sum(group=1)
    ,sum(group=2)
    ,sum(group in (1,2))
  into
     :cnt1 trimmed
    ,:cnt2 trimmed
    ,:cnta trimmed
  from
    phy.&pgm._tajMdlDetail
;quit;

/*
data tst;
x=put('CA',$state2region.);
put x=;
run;quit;
*/

options ls=171 ps=66;
proc sort data=phy.&pgm._sumaddress(keep=npi provider_type nppes_provider_state drug_suppress_indicator nppes_provider_gender)
           out=phy.&pgm._tajinpunq noequals nodupkey;
by npi;
run;quit;

proc sql;
  create
     table phy.&pgm._xpoJynBac (drop=provider_type nppes_provider_state) as
  select
      l.*
     ,case (put(r.nppes_provider_state,$state2region. -l))
       when ( "Northeast Region" )  then 1
       when ( "South Region"     )  then 2
       when ( "Midwest Region"   )  then 3
       when ( "West Region"      )  then 4
       else 5
      end as region
     ,case
       when (prxmatch('/ology|urgery|Internal|Family/',provider_type)>0) then 1
       else 0
      end as Medical
     ,r.*
  from
    phy.&pgm._tajMdlDetail as l, phy.&pgm._tajInpUnq as r
  where
    l.npi = r.npi
;quit;

data phy.&pgm._nrm1st;
  keep  trt question answer;
  length  question  $96;
  set phy.&pgm._xpoJynBac(rename=group=trt);
  question=put(nppes_provider_gender='F',sex.); answer=1;        link all;
  question=put(Medical,srg.);                   answer=1;        link all;
  question=put(region,rgn.);                    answer=1;        link all;
  if _n_=1 then do;                                              link all;
     question=put(1,taj.); trt=1;               answer=&group1;  output  ;
     question=put(2,taj.); trt=2;               answer=&group2;  output  ;
     question=put(1,obs.); trt=1;               answer=&cnt1  ;  output  ;
     question=put(2,obs.); trt=2;               answer=&cnt2  ;  output  ;
     question=put(1,taj.); trt=3;               answer=&groupa;  output  ;
     question=put(1,obs.); trt=3;               answer=&cnta  ;  output  ;
  end;
return;
all:
  output;
  savtrt=trt;
  trt=3;
  output;
  trt=savtrt;
return;
run;quit;

/*
  output;
  savtrt=trt;
  trt=3;
  output;
  trt=savtrt;

proc freq data=phy.&pgm._sumaddress order=freq;
tables provider_type_cd*provider_type/list;
run;quit;
*/

proc sql;
 create
   table shldat  as
 select
   trt
  ,substr(question,1,3) as grp length=3
  ,question
  ,answer
 from
   phy.&pgm._nrm1st
 order
  by grp, trt, question;
;quit;


proc sql;
   create
     table cntpct as
   select
    distinct
     l.trt
    ,l.grp
    ,l.question
    ,r.sumgrp
    ,case
       when (l.trt=1 and l.grp='OBS' ) then cats(put(sum(r.sumgrp),comma12.),' (',put(100*sum(r.sumgrp)/&cnta.,7.1),'%)')
       when (l.trt=2 and l.grp='OBS' ) then cats(put(sum(r.sumgrp),comma12.),' (',put(100*sum(r.sumgrp)/&cnta.,7.1),'%)')
       when (l.trt=3 and l.grp='OBS' ) then cats(put(sum(r.sumgrp),comma12.),' (',put(100*sum(r.sumgrp)/&cnta.,7.1),'%)')
       when (l.trt=1 and l.grp='AJT' ) then cats(put(sum(r.sumgrp),6.1),'%')
       when (l.trt=2 and l.grp='AJT' ) then cats(put(sum(r.sumgrp),6.1),'%')
       when (l.trt=3 and l.grp='AJT' ) then cats(put(sum(r.sumgrp),6.1),'%')
       when (l.trt=1 and l.grp not in ('AJT','OBS')) then cats(put(sum(l.answer),comma12.),' (',put(100*sum(l.answer)/&cnt1.,7.1),'%)')
       when (l.trt=1 ) then cats(put(sum(l.answer),comma12.),' (',put(100*sum(l.answer)/&cnt1.,7.1),'%)')
       when (l.trt=2 ) then cats(put(sum(l.answer),comma12.),' (',put(100*sum(l.answer)/&cnt2.,7.1),'%)')
       else cats(put(sum(l.answer),comma12.),' (',put(100*sum(l.answer)/&cnta.,7.1),'%)')
     end as answer
  from
     shldat as l, (select trt, grp, sum(answer) as sumgrp from shldat group by grp, trt) as r
  where
     l.trt        =  r.trt  and
     l.grp        =  r.grp
  group
     by l.grp, l.trt, l.question
;quit;

proc sort data=cntpct out=cntsrt;
by question trt;
run;quit;

proc transpose data=cntsrt out=xpo(drop=_name_) ;
 by question;
 id trt;
 var answer;
run;

proc sql;
 create
   table phy.&pgm._prerpt as
 select
    input(scan(question,3,'@'),5.) as pge
   ,scan(question,5,'@')           as odr length=3
   ,scan(question,6,'@')           as mjr length=64
   ,scan(question,7,'@')           as mnr length=64
   ,_1  length=24
   ,_2  length=24
   ,_3  length=24
 from
   xpo
 where
   scan(question,5,'@') ne 'XX'
 order
   by pge, odr
;quit;

proc sql;
  select
      _1
     ,_2
     ,_3
  into
     :_1 trimmed
    ,:_2 trimmed
    ,:_3 trimmed
  from
    PRERPT
  where
    odr = '020'
;quit;

*    _ _     _
 ___| (_) __| | ___  ___
/ __| | |/ _` |/ _ \/ __|
\__ \ | | (_| |  __/\__ \
|___/_|_|\__,_|\___||___/

;

/*
%inc "c:/oto/utl_rtflan100.sas";

%utl_rtflan100;
*/

%utl_ymrlan100;

* common slide properties;
%let z=%str(                  );
%let b=%str(font_weight=bold);
%let c=%str(font_face="Courier New");
%let f=%str(font_face="Arial");
%let w=%str(cellwidth=100pct);
%let t=^S={font_size=18pt just=l cellwidth=100pct};

/*
* because I allow macro triggers
use these when you do not want a trigger.
Use double quotes when possible
| to ,
` to single quote
~ to semi colon
# to percent sign
@ to ambersand
*/

title;
footnote;

/* https://communities.sas.com/t5/SAS-GRAPH-and-ODS-Graphics/O-DS-Christmas-Tree/m-p/240189 */

* first slide;


proc sql;
  create
    table phy.&pgm._facAll as
  select
    input(r.year,2.)+2010 as years
   ,l.*
   ,r.*
  from
    phy.&pgm._xpoDetail as l, phy.&pgm._sumFacts as r
  where
    l.npi = r.npi
  order
    by  year, group, npi
;quit;

%let vars=%varlist(phy.&pgm._xpoDetail);
%put &=vars;

%utlnopts;
%array(varx,values=&vars);
%let ren=%do_over(varx,phrase=%nrstr(?=_%substr(?,1,31)));
%put &=ren;

%utlnopts;
data phy.&pgm._facRen(rename=years=year);
  merge
    phy.&pgm._xpoDetail(where=(group=1)  in=one)
    phy.&pgm._xpoDetail(where=(_group=2) in=two
      rename=(&ren.));

    format _all_;
    if two;
    avg_pct = 100*avg_pct;
    _avg_pct = 100*_avg_pct;
    drop year;
run;quit;
%utlopts;

data phy.&pgm._xpoPreGrf;

  set phy.&pgm._tajMdlPlot;
  array nums[*] _numeric_;

  do i=2 to dim(nums);
      nums[i]=sin(nums[i])**2;
  end;

  year=t+2010;

  drop i;

run;quit;

proc transpose data=phy.&pgm._xpopregrf out=phy.&pgm._nrmgrf ;
by year ;
var avg1 avg2 pred1 pred2 l95m1 u95m1 l95m2 u95m2;
run;quit;

data phy.&pgm._nrmgFix;
  length des $44;
  set phy.&pgm._nrmgrf;
  select (_name_);
    when("PRED1") des="Under Allowed Amount   ";
    when("PRED1") des="Close to Allowed Amount";
    otherwise;
  end;
run;quit;


%pdfbeg;

%Tut_Sly
   (
    stop=19
    ,L13 ='^S={font_size=25pt just=c &w}Drug Benificiary Trajectories for General Practice Physicians'
    ,L16 ='^S={font_size=25pt just=c &w}CMS Public Claims data for Years 2012 through 2015'
    ,L17 ='^S={font_size=25pt just=c &w}Drug Beneficiaries as a Percentage of Total Beneficiaries'
    ,L18 ='^S={font_size=25pt just=c &w}The High Trajectory Percentage was 53.9# of Beneficiaries'
    ,L19 ='^S={font_size=25pt just=c &w}The Low Trajectory Percentage was 21.9# of Beneficiaries'
   );

%Tut_Sly
   (
    stop=16
    ,L13 ='^S={font_size=25pt just=c &w}Histograms of Drug and Total Beneficiaries for 2012-2015'
    ,L16 ='^S={font_size=25pt just=c &w}Before ArcSine Transformation of Percentages'
   );

title "General Practice Beneficiaries by Year";
proc sgpanel data=phy.&pgm._facAll(where=(TOTAL_UNIQUE_BENES < 700));
label  TOTAL_DRUG_UNIQUE_BENES="Drug Beneficiaries";
label  TOTAL_UNIQUE_BENES     ="Total Beneficiaries";
panelby years / novarname sparse;
histogram TOTAL_DRUG_UNIQUE_BENES / fillattrs=graphdata1 transparency=0.5 ;
histogram TOTAL_UNIQUE_BENES /fillattrs=graphdata2 transparency=0.7;
run;quit;

%Tut_Sly
   (
    stop=16
    ,L13 ='^S={font_size=25pt just=c &w}Histograms of Transformed Drug and Total Beneficiaries'
    ,L16 ='^S={font_size=25pt just=c &w}ArcSine Transformation of Percentages'
   );

title1 "Percent of Drug Beneficiaries by Year";
title2 "ArcSine Sqare Root Transform of Percentage";
proc sgpanel data=phy.&pgm._tajInp;
label  drug_pct_of_total="Percent Drug Beneficiaries";
label  xpo_drug_pct_of_total="ArcSineSqrt Percent Drug Beneficiaries";
panelby year / novarname sparse;
histogram drug_pct_of_total      / fillattrs=graphdata1 transparency=0.5 ;
histogram xpo_drug_pct_of_total /fillattrs=graphdata2 transparency=0.7;
run;quit;

%Tut_Sly
   (
    stop=16
    ,L13 ='^S={font_size=25pt just=c &w}Mean Drug Beneficiary Percentage by Trajectory'
    ,L16 ='^S={font_size=25pt just=c &w}In originaly Percentage Units'
   );

title1 "Meand of Trajectories of Percent Drug Beneficiaries";
title2 "Low and High Trajectories";
title3 "Raw un-transformed Percentages";
proc sgplot data=phy.&pgm._facRen noautolegend /* tmplout='d:/phy/txt/&pgm._sghst.txt' */;
histogram avg_pct / fillattrs=graphdata1 transparency=0.7  binwidth=3 ;
density avg_pct / lineattrs=graphdata1;
histogram _avg_pct / fillattrs=graphdata2 transparency=0.5  binwidth=3 ;
density _avg_pct / lineattrs=graphdata2;
keylegend " " " " / title=" " noborder;
xaxis grid label="Percent Drug Beneficiaries";
run;quit;

%Tut_Sly
   (
    stop=16
    ,L13 ='^S={font_size=25pt just=c &w}Mean Drug Beneficiary Percentage by Trajectory'
    ,L16 ='^S={font_size=25pt just=c &w}ArcSine Transformation of Units'
   );

title1 "Mean of Trajectories of Percent Drug Beneficiaries";
title2 "Low and High Trajectories";
title3 "ArcSin Transformed Percentages";
proc sgplot data=phy.&pgm._facRen noautolegend /* tmplout='d:/phy/txt/&pgm._sghst.txt' */;
histogram xpo_avg_pct / fillattrs=graphdata1 transparency=0.7  binwidth=.05;
density xpo_avg_pct / lineattrs=graphdata1;
histogram _xpo_avg_pct / fillattrs=graphdata2 transparency=0.5 binwidth=.05;
density _xpo_avg_pct / lineattrs=graphdata2;
keylegend " " " " / title=" " noborder;
xaxis grid label="Percent Drug Beneficiaries";
run;quit;


proc sgplot data=phy.&pgm._nrmgFix(where=(_name_=:'PRED'));
format col1 percent5.2;
title1 "Drug Payments as a Percentage of Allowed Amounts";
label year="Year";
label col1="Percent of Drug Beneficiaries";
series x=year y=col1 / group=des lineattrs=(pattern=solid thickness=1pt color=black)  smoothconnect
datalabel=col1 datalabelattrs=(size=12);
xaxis values=(2012 to 2015 by 1) grid;
yaxis values=(.10 to .60 by .10) grid;
inset "High Percentage of Drug Beneficiaries" / position=BottomLeft;
inset "Low Percentage of Drug Beneficiaries" / position=TopLeft;
keylegend "Close to Allowed Amount" "Close to Allowed Amount" / title="" noborder across=2;
run;quit;

title;
footnote;
proc report data=prerpt(where=(odr ne '060')) nowd split='#' missing style(header)={font_weight=bold};
   cols (
   "^S={outputwidth=100% just=c font_size=15pt font_face=arial}
    Trajectories of Percent Drug Beneficiaries  ^{newline}
    High and Low Percentages  ^{newline}^{newline}
    The High Trajectory Claims were 53.9% of Alowed Amount ^{newline}
    The Low Trajectory Claims were 21.6% of Alowed Amount ^{newline} ^{newline}"
     mjr mnr _1 _2 _3);
    define mjr   / order    noprint order=data;
    define mnr   / display  ""                                         style={cellwidth=20%  just=l } order=data;
    define _1    / display  "Low Percentages#Trajectory#N(%)#&_1.##"   style={cellwidth=26%  just=r } order=data;
    define _2    / display  "High Percentages#N(%)#&_2.##"             style={cellwidth=26%  just=r } order=data;
    define _3    / display  "Total#N(%)#&_3.##"                        style={cellwidth=26%  just=r } order=data;
    compute before mjr / style=[just=l];
      line mjr $96.;
    endcomp;
run;quit;
ods pdf text="^S={font_size=10pt} ^{newline}    ";
ods pdf text="^S={outputwidth=100% just=l font_size=10pt font_style=italic}  Program: c:/utl/&pgm..sas";
ods pdf text="^S={outputwidth=100% just=l font_size=10pt font_style=italic}  Log: d:/phy/log/&pgm..log";
ods pdf text="^S={outputwidth=100% just=l font_size=10pt font_style=italic}  &sysdata &systime";
run;quit;
%pdfend;

*               _
  ___ _ __   __| |
 / _ \ '_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

;

*    _      _        _ _
  __| | ___| |_ __ _(_) |
 / _` |/ _ \ __/ _` | | |
| (_| |  __/ || (_| | | |
 \__,_|\___|\__\__,_|_|_|

;
%macro phy_years(yr);

libname phy "d:/phy";

data phy.phy_100&yr.(compress=yes);
      LENGTH
            npi                                  $10
            nppes_provider_last_org_name         $70
            nppes_provider_first_name            $20
            nppes_provider_mi                    $1
            nppes_credentials                    $20
            nppes_provider_gender                $1
            nppes_entity_code                    $1
            nppes_provider_street1               $55
            nppes_provider_street2               $55
            nppes_provider_city                  $40
            nppes_provider_zip                   $20
            nppes_provider_state                 $2
            nppes_provider_country               $2
            provider_type                        $43
            medicare_participation_indicator     $1
            place_of_service                     $1
            hcpcs_code                           $5
            hcpcs_description                    $256
            hcpcs_drug_indicator                 $1
            line_srvc_cnt                        8
            bene_unique_cnt                      8
            bene_day_srvc_cnt                    8
            average_Medicare_allowed_amt         8
            average_submitted_chrg_amt           8
            average_Medicare_payment_amt         8
            average_Medicare_standard_amt        8;
      INFILE "d:\phy\txt\Medicare_Provider_Util_Payment_PUF_CY201&yr..TXT"

            lrecl=32767
            dlm='09'x
            pad missover
            firstobs = 3
            dsd;

      INPUT
            npi
            nppes_provider_last_org_name
            nppes_provider_first_name
            nppes_provider_mi
            nppes_credentials
            nppes_provider_gender
            nppes_entity_code
            nppes_provider_street1
            nppes_provider_street2
            nppes_provider_city
            nppes_provider_zip
            nppes_provider_state
            nppes_provider_country
            provider_type
            medicare_participation_indicator
            place_of_service
            hcpcs_code
            hcpcs_description
            hcpcs_drug_indicator
            line_srvc_cnt
            bene_unique_cnt
            bene_day_srvc_cnt
            average_Medicare_allowed_amt
            average_submitted_chrg_amt
            average_Medicare_payment_amt
            average_Medicare_standard_amt;

      LABEL
            npi                                 = "National Provider Identifier"
            nppes_provider_last_org_name        = "Last Name/Organization Name of the Provider"
            nppes_provider_first_name           = "First Name of the Provider"
            nppes_provider_mi                   = "Middle Initial of the Provider"
            nppes_credentials                   = "Credentials of the Provider"
            nppes_provider_gender               = "Gender of the Provider"
            nppes_entity_code                   = "Entity Type of the Provider"
            nppes_provider_street1              = "Street Address 1 of the Provider"
            nppes_provider_street2              = "Street Address 2 of the Provider"
            nppes_provider_city                 = "City of the Provider"
            nppes_provider_zip                  = "Zip Code of the Provider"
            nppes_provider_state                = "State Code of the Provider"
            nppes_provider_country              = "Country Code of the Provider"
            provider_type                       = "Provider Type of the Provider"
            medicare_participation_indicator    = "Medicare Participation Indicator"
            place_of_service                    = "Place of Service"
            hcpcs_code                          = "HCPCS Code"
            hcpcs_description                   = "HCPCS Description"
            hcpcs_drug_indicator                = "Identifies HCPCS As Drug Included in the ASP Drug List"
            line_srvc_cnt                       = "Number of Services"
            bene_unique_cnt                     = "Number of Medicare Beneficiaries"
            bene_day_srvc_cnt                   = "Number of Distinct Medicare Beneficiary/Per Day Services"
            average_Medicare_allowed_amt        = "Average Medicare Allowed Amount"
            average_submitted_chrg_amt          = "Average Submitted Charge Amount"
            average_Medicare_payment_amt        = "Average Medicare Payment Amount"
            average_Medicare_standard_amt       = "Average Medicare Standardized Payment Amount";
RUN;

%mend phy_years;

%phy_years(2);
%phy_years(3);
%phy_years(4);
%phy_years(5);

data &pgm._allfor/view=&pgm._allfor;
  retain yr " ";
  set
    phy.phy_1002(in=a)
    phy.phy_1003(in=b)
    phy.phy_1004(in=c)
    phy.phy_1005(in=d)
;
  select;
    when (a)  yr='2';
    when (b)  yr='3';
    when (c)  yr='4';
    when (d)  yr='5';
    otherwise;
 end;

run;quit;

* code decode for lookup;
proc sql;
  create
     table phy.&pgm._cdeDec as
  select
     max(hcpcs_code) as hcpcs_code
    ,max(hcpcs_description) as hcpcs_description
 from
     &pgm._allfor
 group
     by hcpcs_code;
;quit;

/*
Up to 40 obs PHY.PHY_110HPCS_CDEDEC total obs=7,028

  HCPCS_
   CODE     HCPCS_DESCRIPTION

  00100     Anesthesia for procedure on salivary gland with biopsy
  00102     Anesthesia for procedure to repair lip defect present at birth
  00103     Anesthesia for procedure on eyelid
  00104     Anesthesia for electric shock treatment
  00120     Anesthesia for biopsy of external middle and inner ear
  00126     Anesthesia for incision of ear drum
*/


* code decode for lookup provider type;
proc sql;
  *reset inobs=10000;
  create
    table phy.&pgm._typ as
  select
    put(monotonic(),z2.) as type_code
   ,provider_type
  from
   (
    select
       max(provider_type) as provider_type
    from
       &pgm._allfor
    group
      by provider_type
   );
;quit;

proc freq data=phy.&pgm._typ noprint;
tables type_code*provider_type / out=&pgm._typfrq;
run;quit;

/*
TYPE_
CODE     PROVIDER_TYPE

 01      Addiction Medicine
 02      All Other Suppliers
 03      Allergy/Immunology
 04      Ambulance Service Supplier
 05      Ambulatory Surgical Center
 06      Anesthesiologist Assistants
 07      Anesthesiology
 08      Audiologist (billing independently)
 09      CRNA
 10      Cardiac Electrophysiology
 11      Cardiac Surgery
 12      Cardiology
 13      Centralized Flu
 14      Certified Clinical Nurse Specialist
 15      Certified Nurse Midwife
 16      Chiropractic
 17      Clinical Laboratory
 18      Clinical Psychologist
 19      Colorectal Surgery (formerly proctology)
 20      Critical Care (Intensivists)
 21      Dermatology
 22      Diagnostic Radiology
 23      Emergency Medicine
 24      Endocrinology
 25      Family Practice
 26      Gastroenterology
 27      General Practice
 28      General Surgery
 29      Geriatric Medicine
 30      Geriatric Psychiatry
 31      Gynecological/Oncology
 32      Hand Surgery
 33      Hematology
 34      Hematology/Oncology
 35      Hospice and Palliative Care
 36      Independent Diagnostic Testing Facility
 37      Infectious Disease
 38      Internal Medicine
 39      Interventional Cardiology
 40      Interventional Pain Management
 41      Interventional Radiology
 42      Licensed Clinical Social Worker
 43      Mammographic Screening Center
 44      Mass Immunization Roster Biller
 45      Maxillofacial Surgery
 46      Medical Oncology
 47      Multispecialty Clinic/Group Practice
 48      Nephrology
 49      Neurology
 50      Neuropsychiatry
 51      Neurosurgery
 52      Nuclear Medicine
 53      Nurse Practitioner
 54      Obstetrics/Gynecology
 55      Occupational therapist
 56      Ophthalmology
 57      Optometry
 58      Oral Surgery (dentists only)
 59      Orthopedic Surgery
 60      Osteopathic Manipulative Medicine
 61      Otolaryngology
 62      Pain Management
 63      Pathology
 64      Pediatric Medicine
 65      Peripheral Vascular Disease
 66      Pharmacy
 67      Physical Medicine and Rehabilitation
 68      Physical Therapist
 69      Physician Assistant
 70      Plastic and Reconstructive Surgery
 71      Podiatry
 72      Portable X-ray
 73      Preventive Medicine
 74      Psychiatry
 75      Psychologist (billing independently)
 76      Public Health Welfare Agency
 77      Pulmonary Disease
 78      Radiation Oncology
 79      Radiation Therapy
 80      Registered Dietician/Nutrition Professional
 81      Rheumatology
 82      Sleep Medicine
 83      Slide Preparation Facility
 84      Speech Language Pathologist
 85      Sports Medicine
 86      Surgical Oncology
 87      Thoracic Surgery
 88      Unknown Physician Specialty Code
 89      Unknown Supplier/Provider
 90      Urology
 91      Vascular Surgery


Addiction Medicine
Pain Management
Interventional Pain Management

Orthopedic Surgery
Osteopathic Manipulative Medicine
Public Health Welfare Agency
Licensed Clinical Social Worker
Ambulatory Surgical Center
Maxillofacial Surgery
Hand Surgery
Neurosurgery
Plastic and Reconstructive Surgery
Sports Medicine
Thoracic Surgery
General Surgery
Colorectal Surgery (formerly proctology)
*/

* reduce types;
data &pgm._typten surg;
 set &pgm._typfrq;

if index(upcase(provider_type),'SURG') then output surg;
run;quit;

data &pgm._fmt;
  retain fmtname "$&pgm._ptype2code" ;
  set phy.&pgm._typ;
  start=provider_type;
  end=start;
  label=type_code;
run;quit;

options fmtsearch=(phy.formats work.formats);
proc format cntlin=&pgm._fmt lib=phy.phy_formats;
run;quit;

data phy.&pgm._cut;
    length zip $5.;
    set
      &pgm._allfor;
    array avgs[*] average_:;
    zip=substr(nppes_provider_zip,1,5);
    do i=1 to dim(avgs);
       avgs[i]=round(100*avgs[i],1);
    end;
    provider_type_code=put(provider_type,$ptype.);

    nppes_credentials = compbl(upcase(compress(nppes_credentials,',.)(&/')));

    keep
      yr
      average_medicare_payment_amt
      bene_day_srvc_cnt
      bene_unique_cnt
      hcpcs_code
      hcpcs_drug_indicator
      line_srvc_cnt
      medicare_participation_indicator
      npi
      nppes_entity_code
      nppes_provider_country
      nppes_provider_gender
      nppes_provider_state
      place_of_service
      provider_type_code
      nppes_credentials
      zip
    ;
run;quit;

*                    _                  _       _
 _ __ ___   __ _ ___| |_ ___ _ __    __| | __ _| |_ __ _
| '_ ` _ \ / _` / __| __/ _ \ '__|  / _` |/ _` | __/ _` |
| | | | | | (_| \__ \ ||  __/ |    | (_| | (_| | || (_| |
|_| |_| |_|\__,_|___/\__\___|_|     \__,_|\__,_|\__\__,_|

;

*** need to fix **;
proc sql;
  create
    table phy.&pgm._manual as
  select
    l.*
   ,average_medicare_payment_amt ***bene_unique_cnt change to line_srvc_cnt*** as payment
   ,case (r.edd_professions)
      when ('NO')  then 'UNK'
      else edd_professions
   end as edd_professions
  from
    phy.&pgm._cut as l left join phy.&pgm._edddoc as r   /* eddDoc on end */
  on
   l.nppes_credentials eq r.edd_sufix
;quit;



proc sql;
  create
    table phy.&pgm._taj010 as
  select
     npi
    ,yr
    ,average_medicare_payment_amt * line_srvc_cnt as payment
    ,case
       when ( edd_professions in ('MD','DO')) then 1
       else 0
     end as md_pa
    ,case (nppes_provider_gender)
       when ('M') then 0
       else 1
     end as gender
  from
     phy.&pgm._manual
  where
     provider_type_code='27' and edd_professions in ('MD','DO','NP','PA')
  order
     by npi, md_pa, gender, yr;
;quit;

proc summary data=phy.&pgm._taj010 nway;
class npi gender md_pa yr;
var payment;
output out=phy.&pgm._tajsum sum=;
run;quit;

proc transpose data=phy.&pgm._tajsum out=&pgm._tajSumXpo(drop=_name_);
by npi gender md_pa;
id yr;
var payment;
run;quit;

data &pgm._tajAddTym;
 retain t1-t4 .;
 set &pgm._tajSumXpo;
 array tym[4] t1 t2 t3 t4 (1,2,3,4);
 array pays[4] _1 _2 _3 _4;
   do idx=1 to dim(pays);
     if pays[idx] le 1 then pays[idx]=1;
     pays[idx]=log(pays[idx]);
  end;
run;quit;

proc traj data=&pgm._tajAddTym
       out = want_of
   outplot = want_op
   outstat = want_os ci95M;
  id npi;
  var _2-_5 ;
  indep t1-t4;
  risk md_pa gender;
  order 1 1;
  model zip;
run;quit;


options ls=64 ps=44;
proc plot data=WANT_OP;
format t 2.;
plot  (pred1-pred2)*t='*' / overlay haxis=24 to 1 by -1 ;
run;quit;



