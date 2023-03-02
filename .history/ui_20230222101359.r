require(shiny)
require(shinyjs)
require(shinyWidgets)
require(shinyFiles)
require(shinyBS)

linebreaks <- function(n){HTML(strrep(br(), n))}

shinyUI(fluidPage(theme = "bootstrap.css",
  useShinyjs(),
  titlePanel("Welcome to the Stock Synthesis data-limited tool (SS-DL tool)"),
      h4(p(strong("This tool uses the Stock Synthesis framework to implement a ",tags$a(href="javascript:window.open('SS-DL-approaches.html', '_blank','width=600,height=400')", "variety of types"), "of models:"))),
      br(),

sidebarLayout(
   sidebarPanel(
shinyjs::hidden(wellPanel(id="Data_panel",
  h4(strong("Choose data file")),
 fluidRow(column(width=12,fileInput('file2', 'Catch time series',
                           accept = c(
                             'text/csv',
                             'text/comma-separated-values',
                             'text/tab-separated-values',
                             'text/plain',
                             '.csv'
                           )
  ))),
 
  fluidRow(column(width=12,fileInput('file1', 'Length composition',
                                    accept = c(
                                      'text/csv',
                                      'text/comma-separated-values',
                                      'text/tab-separated-values',
                                      'text/plain',
                                      '.csv'
                                    )
  ))),
 
  fluidRow(column(width=12,fileInput('file3', 'Age composition',
            accept = c(
              'text/csv',
              'text/comma-separated-values',
              'text/tab-separated-values',
              'text/plain',
              '.csv'
            )
          ))),

 
  #Mute for now, pull back in when index methods are ready
  fileInput('file4', 'Abundance index',
            accept = c(
              'text/csv',
              'text/comma-separated-values',
              'text/tab-separated-values',
              'text/plain',
              '.csv'
            )
          ),
 
  h4(strong("Clear data files")),
     fluidRow(column(width=3,actionButton("reset_ct", "Catches")),
              column(width=3,actionButton("reset_lt", "Length")),
              column(width=3,actionButton("reset_age", "Ages")),
              column(width=3,actionButton("reset_index", "Index"))), 
  br(),
  br(),
  fluidRow(column(width=10,checkboxInput("user_model","Use existing model?",FALSE))),
  h5(em("Using an existing model allows you to do jitters and other things on a pre-existing model run.")),
  h5(em("Choose Jitters or any of the Additional SS options that do not modify the data or control files.")),
  h5(em("To do sensitivity runs for pre-existing models, make changes in the data_new or control_new files and choose those files in the options list.")),
  h5(em("Make sure the model run is in the Scenarios folder. Put that folder name in the Scenario name input and run the model.")),
)
),
    shinyjs::hidden(wellPanel(id="panel_Ct_F_LO",
        h4(strong("Use constant catch or estimate fishing mortality directly?")),
        h5(em("Using constant catch assumes the same catch in all years in order to fit the length composition data (similar to LBSPR, but the model integrates the fit of each year, not each year separately)")),
        h5(em("It provides a long-term average response (F) to estimating stock status, and thus useful with non-continous years of sampling.")),
        h5(em("Fishing rate can also be directly estimated from the length composition with no assumption in catches (similar to the LIME approach).")),
        h5(em("This approach is a more variable reponse to estimating stock status, and is best used with continuous years of contemporary data. Recruitment can also be estimated.")),
        h5(em("Recruitment can also be estimated in both approaches.")),
        fluidRow(column(width=10,selectInput("Ct_F_LO_select","Approach",c("Choose an option","Constant Catch","Estimate F")))),
      )
    ),
    
    shinyjs::hidden(wellPanel(id="panel_ct_wt_LO",
        h4(strong("Weight fleet lengths by relative catch")),
        h5(em("The relative catch contribution needs specification with multiple length-only fleets")),
        h5(em("Example: Two fleets, with fleet 2 catching 2 times the amount as fleet 1, the entry would be 1,2.")),
        h5(em("Each entry will be relative to the highest value.")),
        fluidRow(column(width=10,textInput("Wt_fleet_Ct","Relative catch values",value=""))),
      )
    ),
    
    shinyjs::hidden(wellPanel(id="panel_data_wt_lt",
        h4(strong("Data-weighting")),
        h5(em("Data weighting balances information content of biological data with model structure")),
        h5(em("Data weighting balances across factors (e.g, fleets, sex, etc.)")),
        h5(em("The default value is equally weighting among fleets based on input effective sample size inputs")),
        h5(em("If using an existing model, chose 'None' to maintain the same weighting as the existing model")),
        # fluidRow(column(width=10,prettyCheckbox(
        #   inputId = "dirichlet",
        #   label = "Use Dirichlet weighting?",
        #   value=FALSE, 
        #   shape="curve",
        #   icon = icon("check"),
        #   animation="smooth"),
        #   bigger=TRUE),
        #   fill=TRUE),
        awesomeRadio(
          inputId = "Data_wt",
          label = "Choose data-weighting option", 
          choices = c("None","Dirichlet", "Francis", "McAllister-Ianelli"),
          selected = "None",
          status = "warning"
          )

        # fluidRow(column(width=6, prettyCheckbox(
        #   inputId = "dirichlet", 
        #   label = "Use Dirichlet weighting?",
        #   shape = "round", 
        #   outline = TRUE, 
        #   status = "info"))), 
        # fluidRow(column(width=6, prettyCheckbox(
        #   inputId = "Francis_wt", 
        #   label = "Use Francis weighting?",
        #   shape = "round", 
        #   outline = TRUE, 
        #   status = "info"))), 
        # fluidRow(column(width=6, prettyCheckbox(
        #   inputId = "MI_wt", 
        #   label = "Use McAllister and Ianelli?",
        #   shape = "round", 
        #   outline = TRUE, 
        #   status = "info"))), 
 
        # h5(em("After the first run, you can check the Francis or harmonic mean methods for suggested weightings")),
        # fluidRow(column(width=6,textInput("Lt_datawts", "Lengths weights by fleet", value=""))),    
      )
    ),

    shinyjs::hidden(wellPanel(id="panel_SSLO_LH",
    h4(strong("Life history inputs")),
        wellPanel(id="panel_SSLO_fixed",
        h5(em("Female")),
        fluidRow(column(width=6,numericInput("M_f", "Natural mortality", value=NA,min=0, max=10000, step=0.00001))),    
        fluidRow(column(width=6,numericInput("Linf_f", "Asymptotic size (Linf)", value=NA,min=0, max=10000, step=0.001)),
                column(width=6,numericInput("k_f","Growth coefficient k", value=NA,min=0, max=10000, step=0.00001))),    
        fluidRow(column(width=6,numericInput("t0_f","Age at length 0 (t0)", value=NA,min=-100, max=10000, step=0.001)),
                column(width=6,textInput("CV_lt_f","CV at length (young then old)", value="0.1,0.1"))),    
        fluidRow(column(width=6,numericInput("L50_f", "Length at 50% maturity", value=NA,min=0, max=10000, step=0.001)),
                column(width=6,numericInput("L95_f","Length at 95% maturity", value=NA,min=0, max=10000, step=0.001))),    
        #h5("Fecundity-length relationship F=aL^b. Set equal to the W-L relationship to get fecundity equivalent to spawning biomass"),
        #fluidRow(column(width=6,numericInput("Fec_a_f", "Coefficient a", value=0.00001,min=0, max=10000, step=-0.01)),
        #        column(width=6,numericInput("Fec_b_f","Exponent b", value=3,min=0, max=10000, step=0.01))),    
        # fluidRow(column(width=6,numericInput("WLa_f", "Weight-Length alpha", value=0.00001,min=0, max=10000, step=0.000000001)),
        #         column(width=6,numericInput("WLb_f","Weight-length beta", value=3,min=0, max=10000, step=0.01))),    
       ),

         fluidRow(column(width=6,checkboxInput("male_parms","Males specific values?",FALSE)),
                  column(width=6,checkboxInput("male_offset","Males offset from females (log(m/f)?",FALSE))),
         # fluidRow(column(width=10,prettyCheckbox("male_parms","Males specific values?",
         #  value=FALSE, 
         #  shape="curve",
         #  icon = icon("check"),
         #  animation="smooth"),
         #  bigger=TRUE),
         #  fill=TRUE,
         #  status="default"),
    #fluidRow(column(width=7, h3("Males specific values?")),column(width=2,checkboxInput("male_parms","Males specific values?",FALSE,width="150%"))),
        wellPanel(
                     uiOutput("Male_parms_inputs_label"),
                     uiOutput("Male_parms_inputs1"),
                     uiOutput("Male_parms_inputs2"),
                     uiOutput("Male_parms_inputs3")
   #                  uiOutput("Male_parms_inputs4")
      ),
    )
    ),

shinyjs::hidden(wellPanel(id="panel_SS_LH_fixed_est_tog",
        
        fluidRow(column(width=10,switchInput("est_parms","Estimate parameters?",
        value=FALSE,
        onLabel = "YES",
        offLabel = "NO",
        onStatus = "success",
        offStatus = "danger"))), 

       h5("Estimating parameters is a data-based approach to determining life history values"),
       h5("Estimating parameters can also propagate parameter uncertainty into derived model outputs"),
       br(),
       h5("When estimating parameters with catch and length (SS-CL) models consider:"),
       tags$ul(tags$li(h5(p("It is recommended to run the model first by fixing parameters.")))),
       tags$ul(tags$li(h5(p("Then run likelihood profiles to see if the data contain any information on parameters.")))),
       tags$ul(tags$li(h5(p("Parameters that seem informed by the data (i.e., result in realistic values) are good candidates for estimation.")))),
       tags$ul(tags$li(h5(p("The most likely parameters to have information from fishery-based lengths are Linf and M.")))),
       h5("Not all parameters need be estimated. Fix parameters by turning the phase negative (e.g., -1)"),
       
)),

  shinyjs::hidden(wellPanel(id="panel_SS_LH_fixed",
    h4(strong("Life history inputs")),
        wellPanel(id="panel_SS_fixed",
        h5(em("Female")),
        fluidRow(column(width=6,numericInput("M_f_fix", "Natural mortality", value=NA,min=0, max=10000, step=0.00001))),    
        fluidRow(column(width=6,numericInput("Linf_f_fix", "Asymptotic size (Linf)", value=NA,min=0, max=10000, step=0.001)),
                column(width=6,numericInput("k_f_fix","Growth coefficient k", value=NA,min=0, max=10000, step=0.00001))),    
        fluidRow(column(width=6,numericInput("t0_f_fix","Age at length 0 (t0)", value=NA,min=0, max=10000, step=0.001)),
                column(width=6,textInput("CV_lt_f_fix","CV at length (young then old)", value="0.1,0.1"))),    
        fluidRow(column(width=6,numericInput("L50_f_fix", "Length at 50% maturity", value=NA,min=0, max=10000, step=0.001)),
                column(width=6,numericInput("L95_f_fix","Length at 95% maturity", value=NA,min=0, max=10000, step=0.001))),    
        h5("Length-weight relationship W=aL^b. Weight is in kg and length in cm."),
        fluidRow(column(width=6,numericInput("WLa_f_fix", "a in W=aL^b", value=0.00001,min=0, max=10000, step=0.000000001)),
                column(width=6,numericInput("WLb_f_fix","b in W=aL^b", value=3,min=0, max=10000, step=0.0001))),    
        h5("Length-fecundity relationship F=aL^b. Fecundity is measured in number of eggs or pups. Set equal to the length-weight relationship to get fecundity equivalent to spawning biomass."),
        fluidRow(column(width=6,numericInput("Fec_a_f_fix", "a in F=aL^b", value=0.00001,min=0, max=10000, step=0.000000001)),
                column(width=6,numericInput("Fec_b_f_fix","b in F=aL^b", value=3,min=0, max=10000, step=0.0001))),
            
       ),

        fluidRow(column(width=10,checkboxInput("male_parms_fix","Males specific values?",FALSE)),
                 column(width=10,checkboxInput("male_offset_fix","Males offset from females (log(m/f)?",FALSE))),
    #fluidRow(column(width=7, h3("Males specific values?")),column(width=2,checkboxInput("male_parms","Males specific values?",FALSE,width="150%"))),
        wellPanel(
                     uiOutput("Male_parms_inputs_label_fix"),
                     uiOutput("Male_parms_inputs1_fix"),
                     uiOutput("Male_parms_inputs2_fix"),
                     uiOutput("Male_parms_inputs3_fix"),
                     uiOutput("Male_parms_inputs4_fix")
      ),
    )
    ),

    shinyjs::hidden(wellPanel(id="panel_SS_LH_est",
    h4(strong("Life history inputs")),
#      fluidRow(column(width=10,switchInput("est_parms2","Estimate parameters?",value=TRUE))),      
      wellPanel(id="panel_SS_est",
      h4(em("Female")),
        dropdownButton(
          selectInput("M_f_prior","Prior type",c("no prior","symmetric beta", "beta","lognormal","gamma","normal")),
          numericInput("M_f_mean", "Mean", value=NA,min=0, max=10000, step=0.00001),
          numericInput("M_f_SD", "SD", value=0,min=0, max=10000, step=0.00001),
          numericInput("M_f_phase", "Phase", value=-1,min=-999, max=10, step=1),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("skull-crossbones"), width = "300px",label="Natural mortality"
            ),
      br(),
       h5(strong("Growth")),            
       dropdownButton(
          selectInput("Linf_f_prior","Prior type",c("no prior","symmetric beta", "beta","lognormal","gamma","normal")),
          numericInput("Linf_f_mean", "Mean", value=NA,min=0, max=10000, step=0.001),
          numericInput("Linf_f_SD", "SD", value=0,min=0, max=10000, step=0.0001),
          numericInput("Linf_f_phase", "Phase", value=-1,min=-999, max=10, step=1),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("infinity"), width = "300px",label="Linf: Asymptotic size"
          ),
     br(),
      dropdownButton(
          selectInput("k_f_prior","Prior type",c("no prior","symmetric beta", "beta","lognormal","gamma","normal")),
          numericInput("k_f_mean", "Mean", value=NA,min=0, max=10000, step=0.00001),
          numericInput("k_f_SD", "SD", value=0,min=0, max=10000, step=0.00001),
          numericInput("k_f_phase", "Phase", value=-1,min=-999, max=10, step=1),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("ruler-horizontal"), width = "300px",label="k: VB growth coefficient"
            ),
     br(),
      dropdownButton(
          selectInput("t0_f_prior","Prior type",c("no prior","symmetric beta", "beta","lognormal","gamma","normal")),
          numericInput("t0_f_mean", "Mean", value=NA,min=-100, max=10000, step=0.001),
          numericInput("t0_f_SD", "SD", value=0,min=0, max=10000, step=0.001),
          numericInput("t0_f_phase", "Phase", value=-1,min=-999, max=10, step=1),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("baby-carriage"), width = "300px",label="t0: Age at size 0"
            ),
     br(),
       dropdownButton(
          selectInput("CV_lt_f_young_prior","Prior type",c("no prior","symmetric beta", "beta","lognormal","gamma","normal")),
          numericInput("CV_lt_f_young_mean", "Mean", value=0.1,min=0, max=10000, step=0.0001),
          numericInput("CV_lt_f_young_SD", "SD", value=0,min=0, max=10000, step=0.0001),
          numericInput("CV_lt_f_young_phase", "Phase", value=-1,min=-999, max=10, step=1),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("dice"), width = "300px",label="CV at length (young)"
            ),

     br(),
       dropdownButton(
          selectInput("CV_lt_f_old_prior","Prior type",c("no prior","symmetric beta", "beta","lognormal","gamma","normal")),
          numericInput("CV_lt_f_old_mean", "Mean", value=0.1,min=0, max=10000, step=0.0001),
          numericInput("CV_lt_f_old_SD", "SD", value=0,min=0, max=10000, step=0.0001),
          numericInput("CV_lt_f_old_phase", "Phase", value=-1,min=-999, max=10, step=1),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("dice"), width = "300px",label="CV at length (old)"
            ),

    h5(strong("Maturity and weight-length relationships")),            
      fluidRow(column(width=6,numericInput("L50_f_est", "Length at 50% maturity", value=NA,min=0, max=10000, step=0.001)),
              column(width=6,numericInput("L95_f_est","Length at 95% maturity", value=NA,min=0, max=10000, step=0.001))),    
        h5("Length-weight relationship W=aL^b. Weight is in kg and length in cm."),
      fluidRow(column(width=6,numericInput("WLa_f_est", "a in W=aL^b", value=0.00001,min=0, max=10000, step=0.000000001)),
              column(width=6,numericInput("WLb_f_est","b in W=aL^b", value=3,min=0, max=10000, step=0.001))),    
        h5("Length-fecundity relationship F=aL^b. Fecundity is measured in number of eggs or pups. Set equal to the length-weight relationship to get fecundity equivalent to spawning biomass."),
        fluidRow(column(width=6,numericInput("Fec_a_f_est", "a in F=aL^b", value=0.00001,min=0, max=10000, step=0.000000001)),
              column(width=6,numericInput("Fec_b_f_est","b in F=aL^b", value=3,min=0, max=10000, step=0.001))),    
    ),
      fluidRow(column(width=6,checkboxInput("male_parms_est","Males specific values?",FALSE)),
               column(width=6,checkboxInput("male_offset_est","Males offset from females (log(m/f))?",FALSE))),
    #fluidRow(column(width=7, h3("Males specific values?")),column(width=2,checkboxInput("male_parms","Males specific values?",FALSE,width="150%"))),
      wellPanel(
                     uiOutput("Male_parms_inputs_label_est"),
                     uiOutput("Male_parms_inputs_M_est"),
                     uiOutput("Male_parms_inputs_space1"),
                     uiOutput("Male_parms_inputs_Growth_label"),
                     uiOutput("Male_parms_inputs_Linf_est"),
                     uiOutput("Male_parms_inputs_space2"),
                     uiOutput("Male_parms_inputs_k_est"),
                     uiOutput("Male_parms_inputs_space3"),
                     uiOutput("Male_parms_inputs_t0_est"),
                     uiOutput("Male_parms_inputs_space4"),
                     uiOutput("Male_parms_inputs_CV_est_young"),
                     br(),
                     uiOutput("Male_parms_inputs_CV_est_old"),
                     uiOutput("Male_parms_inputs_space5"),
                     uiOutput("Male_parms_inputs_WL_est")
        ),
      )
    ),

   #  shinyjs::hidden(wellPanel(id="panel_SS_est",
   #  h3("Life history inputs"),
   #    fluidRow(column(width=10,switchInput("est_parms2","Fix parameters?"))),      
   #    wellPanel(
   #    h4(em("Female")),
   #    fluidRow(column(width=6,numericInput("Nages","Max. age", value=NA,min=1, max=1000, step=1))),
   #    h5(strong("Natural mortality")),            
   #    fluidRow(column(width=4,style='padding:1px;',align="center", selectInput("M_prior","Prior type",c("lognormal","truncated normal","uniform","beta"))),
   #            column(width=3,style='padding:2px;',align="center",numericInput("M_f_mean", "Mean", value=NA,min=0, max=10000, step=0.001)),    
   #            column(width=3,style='padding:2px;',align="center",numericInput("M_f_SD", "SD", value=0,min=0, max=10000, step=0.001)),    
   #            column(width=2,style='padding:2px;',align="center",numericInput("M_f_phase", "Phase", value=-1,min=-999, max=10, step=0.001))),    
   #    h5(strong("Growth")),            
   #    h5(strong("Linf")),            
   #    fluidRow(column(width=4,style='padding:1px;',align="center",selectInput("Linf_f_prior","Prior type",c("lognormal","truncated normal","uniform","beta"))),
   #            column(width=3,style='padding:2px;',align="center",numericInput("Linf_f_mean", "Mean", value=NA,min=0, max=10000, step=0.001)),    
   #            column(width=3,style='padding:2px;',align="center",numericInput("Linf_f_SD", "SD", value=0,min=0, max=10000, step=0.001)),    
   #            column(width=2,style='padding:2px;',align="center",numericInput("Linf_f_phase", "Phase", value=-1,min=-999, max=10, step=0.001))),    
   # h5(strong("k")),            
   #    fluidRow(column(width=4,style='padding:2px;',selectInput("k_f_prior","Prior type",c("lognormal","truncated normal","uniform","beta"))),
   #            column(width=3,style='padding:2px;',numericInput("k_f_mean", "Mean", value=NA,min=0, max=10000, step=0.001)),    
   #            column(width=3,style='padding:2px;',numericInput("k_f_SD", "SD", value=0,min=0, max=10000, step=0.001)),    
   #            column(width=2,style='padding:2px;',align="center",numericInput("k_f_phase", "Phase", value=-1,min=-999, max=10, step=0.001))),    
   #  h5(strong("t0")),            
   #    fluidRow(column(width=4,style='padding:2px;',selectInput("t0_f_prior","Prior type",c("lognormal","truncated normal","uniform","beta"))),
   #            column(width=3,style='padding:2px;',numericInput("t0_f_mean", "Mean", value=NA,min=0, max=10000, step=0.001)),    
   #            column(width=3,style='padding:2px;',numericInput("t0_f_SD", "SD", value=0,min=0, max=10000, step=0.001)),    
   #            column(width=2,style='padding:2px;',align="center",numericInput("t0_f_phase", "Phase", value=-1,min=-999, max=10, step=0.001))),    
   #  h5(strong("Length CV")),            
   #    fluidRow(column(width=4,style='padding:2px;',selectInput("CV_f_prior","Prior type",c("lognormal","truncated normal","uniform","beta"))),
   #            column(width=3,style='padding:2px;',numericInput("CV_f_mean", "Mean", value=0.1,min=0, max=10000, step=0.001)),    
   #            column(width=3,style='padding:2px;',numericInput("CV_f_SD", "SD", value=0,min=0, max=10000, step=0.001)),    
   #            column(width=2,style='padding:2px;',align="center",numericInput("CV_f_phase", "Phase", value=-1,min=-999, max=10, step=0.001))),    

   #  h5(strong("Maturity and weight-length relationships")),            
   #    fluidRow(column(width=6,numericInput("L50_f", "Length at 50% maturity", value=NA,min=0, max=10000, step=0.01)),
   #            column(width=6,numericInput("L95_f","Length at 95% maturity", value=NA,min=0, max=10000, step=0.01))),    
   #    fluidRow(column(width=6,numericInput("Fec_a", "Wt-based fec coeff", value=1,min=0, max=10000, step=-0.01)),
   #            column(width=6,numericInput("Fec_b","Wt-based fec exp", value=1,min=0, max=10000, step=0.01))),    
   #    fluidRow(column(width=6,numericInput("WLa_f", "Weight-Length alpha", value=0.00001,min=0, max=10000, step=0.000000001)),
   #            column(width=6,numericInput("WLb_f","Weight-length beta", value=3,min=0, max=10000, step=0.01))),    
   #  ),
   #    fluidRow(column(width=10,checkboxInput("male_parms_est","Males specific values?",FALSE))),
   #  #fluidRow(column(width=7, h3("Males specific values?")),column(width=2,checkboxInput("male_parms","Males specific values?",FALSE,width="150%"))),
   #    wellPanel(
   #                   uiOutput("Male_parms_inputs_label_est"),
   #                   uiOutput("Male_parms_inputs1_est"),
   #                   uiOutput("Male_parms_inputs2_est"),
   #                   uiOutput("Male_parms_inputs3_est"),
   #                   uiOutput("Male_parms_inputs4_est")
   #    ),
   #  )
   #  ),

    shinyjs::hidden(wellPanel(id="panel_SSS",
    h4(strong("Life history inputs")),
    h5(em("If using the uniform prior, low and high range go in the mean and SD input, respectively.")),
    wellPanel(
      h4(em("Female")),
      h5(strong("Natural mortality")),            
        dropdownButton(
          selectInput("M_prior_sss","Prior type",c("lognormal","normal","uniform","no prior")),
          numericInput("M_f_mean_sss", "Mean", value=NA,min=0, max=10000, step=0.00001),
          numericInput("M_f_SD_sss", "SD", value=0.44,min=0, max=10000, step=0.00001),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("skull-crossbones"), width = "300px",label="Natural mortality"
            ),
      h5(strong("Growth")),            
          dropdownButton(
          selectInput("Linf_f_prior_sss","Prior type",c("no prior","normal")),
          numericInput("Linf_f_mean_sss", "Mean", value=NA,min=0, max=10000, step=0.001),
          numericInput("Linf_f_SD_sss", "SD", value=0,min=0, max=10000, step=0.001),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("infinity"), width = "300px",label="Linf: Asymptotic size"
          ),
     br(),
      dropdownButton(
          selectInput("k_f_prior_sss","Prior type",c("no prior","normal")),
          numericInput("k_f_mean_sss", "Mean", value=NA,min=0, max=10000, step=0.00001),
          numericInput("k_f_SD_sss", "SD", value=0,min=0, max=10000, step=0.00001),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("ruler-horizontal"), width = "300px",label="k: VB growth coefficient"
            ),
     br(),
     fluidRow(column(width=6,numericInput("Linf_k_cor_sss", "Correlation between Linf and k", value=-0.9,min=-1, max=1, step=0.001))),
     br(),
      dropdownButton(
          selectInput("t0_f_prior_sss","Prior type",c("no prior","normal")),
          numericInput("t0_f_mean_sss", "Mean", value=NA,min=-100, max=10000, step=0.001),
          numericInput("t0_f_SD_sss", "SD", value=0,min=0, max=1000, step=0.001),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("baby-carriage"), width = "300px",label="t0: Age at size 0"
            ),
    h5(em("Length CV")),            
      dropdownButton(
          selectInput("CV_lt_f_young_prior_sss","Prior type",c("no prior")),
          numericInput("CV_lt_f_young_mean_sss", "Mean", value=0.1,min=0, max=10000, step=0.0001),
          numericInput("CV_lt_f_young_SD_sss", "SD", value=0,min=0, max=10000, step=0.0001),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("dice"), width = "300px",label="CV at length"
            ),
      dropdownButton(
          selectInput("CV_lt_f_old_prior_sss","Prior type",c("no prior")),
          numericInput("CV_lt_f_old_mean_sss", "Mean", value=0.1,min=0, max=10000, step=0.0001),
          numericInput("CV_lt_f_old_SD_sss", "SD", value=0,min=0, max=10000, step=0.0001),
          circle = FALSE, right=TRUE, status = "danger", icon = icon("dice"), width = "300px",label="CV at length"
            ),
    h5(strong("Maturity and weight-length relationships")),            
      fluidRow(column(width=6,numericInput("L50_f_sss", "Length at 50% maturity", value=NA,min=0, max=10000, step=0.001)),
              column(width=6,numericInput("L95_f_sss","Length at 95% maturity", value=NA,min=0, max=10000, step=0.001))),
      h5("Length-weight relationship W=aL^b. Weight is in kg and length in cm."),
      fluidRow(column(width=6,numericInput("WLa_f_sss", "a in W=aL^b", value=0.00001,min=0, max=10000, step=0.000000001)),
              column(width=6,numericInput("WLb_f_sss","b in W=aL^b", value=3,min=0, max=10000, step=0.001))),    
      h5("Length-fecundity relationship F=aL^b. Fecundity is measured in number of eggs or pups. Set equal to the length-weight relationship to get fecundity equivalent to spawning biomass."),
      fluidRow(column(width=6,numericInput("Fec_a_f_sss", "a in F=aL^b", value=0.00001,min=0, max=10000, step=0.000000001)),
              column(width=6,numericInput("Fec_b_f_sss","b in F=aL^b", value=3,min=0, max=10000, step=0.001))),    
    ),
    
    fluidRow(column(width=10,checkboxInput("male_parms_SSS","Males specific values?",FALSE)),
      column(width=10,checkboxInput("male_offset_SSS","Males offset to females (log(m/f)?",FALSE))),
    #fluidRow(column(width=7, h3("Males specific values?")),column(width=2,checkboxInput("male_parms_SSS","Males specific values?",FALSE,width="150%"))),
    wellPanel(
                     uiOutput("Male_parms_inputs_label_SSS"),
                     uiOutput("Male_parms_inputs_M_SSS"),
                     uiOutput("Male_parms_inputs_space1_SSS"),
                     uiOutput("Male_parms_inputs_Growth_label_SSS"),
                     uiOutput("Male_parms_inputs_Linf_SSS"),
                     uiOutput("Male_parms_inputs_space2_SSS"),
                     uiOutput("Male_parms_inputs_k_SSS"),
                     uiOutput("Male_parms_inputs_space3_SSS"),
                     uiOutput("Male_parms_inputs_t0_SSS"),
                     uiOutput("Male_parms_inputs_space4_SSS"),
                     uiOutput("Male_parms_inputs_CV_young_SSS"),
                     uiOutput("Male_parms_inputs_CV_old_SSS"),
                     uiOutput("Male_parms_inputs_WL_SSS")
     ),
     )
    ),

#SSS Stock status input
    shinyjs::hidden(wellPanel(id="panel_SS_stock_status",
    h4(strong("Relative stock status")),
      #wellPanel(
         fluidRow(column(width=6,numericInput("status_year", "Relative stock status year", value=NA,min=1000, max=3000, step=1))),
         dropdownButton(
          selectInput("Depl_prior_sss","Prior type",c("beta","lognormal","truncated normal","uniform","no prior")),
          numericInput("Depl_mean_sss", "Mean", value=NA,min=0.001, max=1, step=0.001),
          numericInput("Depl_SD_sss", "SD", value=0.2,min=0, max=1000, step=0.001),
          circle = FALSE, status = "danger", icon = icon("battery-half"), width = "300px",label="Relative Stock Status"
       ) 
      )
    ),  


################################
#Stock-recruitment/Productivity#
################################

    shinyjs::hidden(wellPanel(id="panel_SSS_prod",
    h4(strong("Stock-recruitment parameters")),
          br(),
          fluidRow(column(width=6,numericInput("lnR0_sss", "Initial recruitment (lnR0)", value=7,min=0.01, max=20, step=0.01))),
          dropdownButton(
          selectInput("h_prior_sss","Steepness",c("symmetric beta","beta","truncated normal","truncated lognormal","uniform","no prior")),
          numericInput("h_mean_sss", "Mean", value=0.7,min=0.2, max=1, step=0.001),
          numericInput("h_SD_sss", "SD", value=0.15,min=0, max=10000, step=0.001),
          circle = FALSE, status = "danger", icon = icon("recycle"), width = "300px",label="Steepness"
       ),   
      )
    ),  

    shinyjs::hidden(wellPanel(id="panel_SS_LO_prod",
    h4(strong("Stock-recruitment parameters")),
   #   wellPanel(
     fluidRow(column(width=6,numericInput("h_LO","Steepness", value=0.7,min=0.2, max=1, step=0.01))),
   #    ),
      )
    ),  

    shinyjs::hidden(wellPanel(id="panel_SS_prod_fixed",
    h4(strong("Stock-recruitment parameters")),
   #   wellPanel(
     fluidRow(column(width=6,numericInput("h","Steepness", value=0.7,min=0.2, max=1, step=0.01)),
      column(width=6,numericInput("lnR0", "Initial recruitment (lnR0)", value=7,min=0.01, max=20, step=0.01))),
   #    ),
      )
    ),  

    shinyjs::hidden(wellPanel(id="panel_SS_prod_est",
    h4(strong("Stock-recruitment parameters")),
     # wellPanel(
       dropdownButton(
          selectInput("h_ss_prior","Prior type",c("no prior","symmetric beta", "beta","lognormal","gamma","normal")),
          numericInput("h_mean_ss", "Mean", value=0.7,min=0.2, max=1, step=0.001),
          numericInput("h_SD_ss", "SD", value=0.15,min=0, max=10000, step=0.001),
          numericInput("h_phase", "Phase", value=-1,min=-999, max=10, step=0.001),
          circle = FALSE, status = "danger", icon = icon("recycle"), width = "300px",label="Steepness"
       ), 
     fluidRow(column(width=6,numericInput("lnR0_est", "Initial recruitment (lnR0)", value=9,min=0, max=20, step=0.01))),
  )), 

    #      fluidRow(column(width=4,style='padding:1px;',align="center", selectInput("h_ss_prior","Steepness",c("beta","symmetric beta","truncated normal","trunc lognormal","uniform"))),
    #           column(width=3,style='padding:2px;',align="center",numericInput("h_mean_ss", "Mean", value=0.7,min=0, max=10000, step=0.001)),    
    #           column(width=3,style='padding:2px;',align="center",numericInput("h_SD_ss", "SD", value=0.15,min=0, max=10000, step=0.001)), 
    #           column(width=2,style='padding:2px;',align="center",numericInput("h_phase", "Phase", value=-1,min=-999, max=10, step=0.001))),    
    #      fluidRow(column(width=6,numericInput("lnR0_est", "Initial recruitment (lnR0)", value=9,min=0, max=20, step=0.01))),
    #   #  ),
    #   )
    # ),  



   #Recruitment estimation
    shinyjs::hidden(wellPanel(id="panel_SS_recdevs",
    fluidRow(column(width=10,checkboxInput("rec_choice","Estimate recruitment?",FALSE))),
    wellPanel(
    #          fluidRow(column(width=8,offset=-10, h3("Estimate recruitment?")),column(width=6,checkboxInput("rec_choice","",FALSE))),
    #          fluidRow(column(width=8, h3("Estimate recruitment?")),column(width=4,radioButtons("rec_choice","",FALSE))),
   tags$style("
       .checkbox { /* checkbox is a div class*/
       #  line-height: 10px;
         margin-bottom: 0px; 
        margin-left: 0px;
        font-size: 20px;
       }
      input[type='checkbox']{ /* style for checkboxes */
          width: 20px; /*Desired width*/
          height: 20px; /*Desired height*/
          line-height: 100px; 
        
        # span { 
        #   margin-left: 30px;  /*set the margin, so boxes don't overlap labels*/
        #   line-height: 30px; 
      }

       }"),
                   uiOutput("Rec_options1"),
                   uiOutput("Rec_options2"),
                  fluidRow(column(width=10,checkboxInput("biasC_choice","Bias correct recruitments?",FALSE))),
                   h5("Years of no bias correction"),
                   uiOutput("Rec_options3"),
                   h5("Years of bias correction"),
                   uiOutput("Rec_options4"),
                   uiOutput("Rec_options5") 
                ),
        )
     ),

#Selectivity
    shinyjs::hidden(wellPanel(id="panel_selectivity_sss",
  #   wellPanel(
    h4(strong("Selectivity")),
    h5("Enter parameter values for each fleet and survey."), 
    h5("Example using 50% selectivity with two fleets: Inputs could be 35,40 for starting values."),
    p("If using a mix of logistic and dome-shaped selectivities, select", strong("dome-shaped"),"and use the default values (10000,0.0001,0.9999 for the additonal parameters, respectively) to achieve a logistic shape for any given fleet."),
    br(),
    fluidRow(selectInput("Sel_choice_sss","Length selectivity type",c("Logistic","Dome-shaped"))),

       uiOutput("Sel_parms1_sss"),
       uiOutput("Sel_parms2_sss"),
       uiOutput("Sel_parms3_sss")
      )
   ), 

    shinyjs::hidden(wellPanel(id="panel_selectivity",
  #   wellPanel(
    h4(strong("Selectivity")),
    h5("Enter parameter and phase values for each fleet and survey."), 
    h5("Example using 50% selectivity with two fleets: Inputs could be 35,40 and 2,2 for starting values and phases respectively."),
    h5("The phase input indicates estimated parameters. To fix the parameter, set the phase value to a negative number."),
    p("If using a mix of logistic and dome-shaped selectivities, select", strong("dome-shaped"),"and fix (i.e., use a negative phase) the provided default values (10000,0.0001,0.9999 for the additonal parameters, respectively) to achieve a logistic shape for any given fleet."),
    br(),
    fluidRow(selectInput("Sel_choice","Length selectivity type",c("Logistic","Dome-shaped"))),
    # fluidRow(column(width=6,numericInput("Sel50", "Length at 50% Selectivity", value=NA,min=0, max=10000, step=0.01)),
    #         column(width=6,numericInput("Sel50_phase","Estimation phase", value=1,min=-1000, max=10, step=1))),   
    # fluidRow(column(width=6,numericInput("Selpeak", "Length at Peak Selectvity", value=NA,min=0, max=10000, step=0.01)),
    #         column(width=6,numericInput("Selpeak_phase","Estimation phase", value=1,min=-1000, max=10, step=1))),   
              #if(input$Sel_choice=="Logistic")
              #  {uiOutput("Sel_logistic")},
              #if(input$Sel_choice=="Dome-shaped")
              #  {uiOutput("Sel_domed")}
       uiOutput("Sel_parms1"),
       uiOutput("Sel_parms2"),
       uiOutput("Sel_parms3"),
       uiOutput("Sel_parms4"),
       uiOutput("Sel_parms5"),

    fluidRow(checkboxInput("Sex_lt_sel","Sex-specific selectivity?",FALSE)),
    
    fluidRow(checkboxInput("age_sel_choice","Age-based selectivity?",FALSE))
     
       
  #      ),
      )
   ), 
    #Jitter inputs
#    shinyjs::hidden(wellPanel(id="panel_SS_jitter1",
    shinyjs::hidden(wellPanel(id="panel_SS_jitter",
     fluidRow(column(width=10,checkboxInput("jitter_choice","Jitter starting values?",FALSE))),
              uiOutput("Jitter_value"),
              h5("Jittering refers to changing the input starting values."),
              h5("Jittering provides a quick way to adjust starting values for two main purposes:"),
                tags$ul(tags$li(h5(p("Start the model at different values to assist model convergence.")))),
                tags$ul(tags$li(h5(p("Validate global versus local model convergence. This requires running many models at different jittered starting values to make sure a lower minimized likelihood value is not found. If a lower likelihood value is found, that would be considered the best fit model.")))),
              h5("Run just 1 jitter value to find a converged model. Then run multiple jittered models to confrim that model is the best fit model."),
          )
      ),

    #Reference Points
     shinyjs::hidden(wellPanel(id="panel_RPs",
     fluidRow(column(width=10,checkboxInput("RP_choices","Define reference points?",FALSE))),
          uiOutput("RP_selection1"),
          uiOutput("RP_selection2")
          )
        ),
     
  #Forecast options
    shinyjs::hidden(wellPanel(id="panel_Forecasts",
    fluidRow(column(width=10,checkboxInput("Forecast_choice","Define forecasts?",FALSE))),
          uiOutput("Forecasts")
        )
        ),

    shinyjs::hidden(wellPanel(id="panel_Mod_dims",
    h4(strong("Model dimensions: years and ages")),
    h5(p(em("Starting year values based on first year of data inputs"))),
#      tags$ul(tags$li(h5(p(em("If catch data is used, starting and ending model years are based on the time series of catch"))))),
#      tags$ul(tags$li(h5(p(em("If using only length or age data, starting model year is based on earliest year minus age at 95% Linf"))))),
    # h5(p(em("Start year recommendations are:"))),
    #   tags$ul(tags$li(h5(p(em("If length data only, count the year back from the first year of length data based on maximum age likely contained in length data"))))),
    #   tags$ul(tags$li(h5(p(em("If using catch data, use the first year of catches"))))),
    # h5(p(em(""))),
      uiOutput("Model_dims1"),
    #  uiOutput("Model_dims2"),
      )
    ),
   

    shinyjs::hidden(wellPanel(id="panel_advanced_SS",
    h4(strong("Additional SS options")),
    #fluidRow(column(width=10,checkboxInput("advance_ss_click","Advanced SS options",FALSE))),
      uiOutput("AdvancedSS_nohess"),
      uiOutput("AdvancedSS_noplots"),
      uiOutput("AdvancedSS_par"),
      uiOutput("AdvancedSS_datanew"),
      uiOutput("AdvancedSS_controlnew"),
      uiOutput("AdvancedSS_forecastnew"),
      uiOutput("AdvancedSS_phase0"),
      uiOutput("AdvancedSS_Sex3"),
      uiOutput("AdvancedSS_Indexvar"),
      uiOutput("AdvancedSS_ageerror"),
      uiOutput("AdvancedSS_ageerror_in"),
      uiOutput("AdvancedSS_Ctunits"),
      uiOutput("AdvancedSS_Ctunitsfleets"),
      uiOutput("AdvancedSS_GT1"),
      uiOutput("AdvancedSS_retro_choice"),
      uiOutput("AdvancedSS_retro_years"),
      h5(p("Define modelled length bins. Default values are by 2 cm bin ranging from 4 to 25% above the Linf value. If using conditional age at lengths, length bins must be consistent with these population bins, not the length data bins.")),
      h5(p(em("Inputs must be smaller and larger than the length compositin bins. Input values will be overridden to meet this requirement"))),
      uiOutput("AdvancedSS_Ltbin")
      
     #  prettyCheckbox(
     #    inputId = "no_hess", label = "Turn off Hessian",
     #    shape = "round", outline = TRUE, status = "info"),    
     #  prettyCheckbox(
     #    inputId = "no_plots_tables", label = "Turn off plots and tables",
     #    shape = "round", outline = TRUE, status = "info"),    
     # prettyCheckbox(
     #    inputId = "GT1", label = "Use only one growth type",
     #    shape = "round", outline = TRUE, status = "info"),    
     # prettyCheckbox(
     #    inputId = "Sex3", label = "Retain sex ratio in length compositions (Sex = 3)",
     #    shape = "round", outline = TRUE, status = "info"),    
      )
     ),

    shinyjs::hidden(wellPanel(id="panel_advanced_user_SS",
    h4(strong("Additional SS options")),
    #fluidRow(column(width=10,checkboxInput("advance_ss_click","Advanced SS options",FALSE))),
      uiOutput("AdvancedSS_nohess_user"),
      uiOutput("AdvancedSS_noplots_user"),
      uiOutput("AdvancedSS_par_user"),
      uiOutput("AdvancedSS_datanew_user"),
      uiOutput("AdvancedSS_controlnew_user"),
      uiOutput("AdvancedSS_forecastnew_user"),
      uiOutput("AdvancedSS_phase0_user"),
      uiOutput("AdvancedSS_retro_choice_user"),
      uiOutput("AdvancedSS_retro_years_user")
      )
     ),

    shinyjs::hidden(wellPanel(id="panel_advanced_SSS",
    h4(strong("Additional SS options")),
    h5(strong("Choosing catch units")),
    h6(strong("Default is biomass (in MT), but click below button to specify for each fleet.")),
    #fluidRow(column(width=10,checkboxInput("advance_ss_click","Advanced SS options",FALSE))),
      uiOutput("AdvancedSS_Ctunits_SSS"),
      uiOutput("AdvancedSS_Ctunitsfleets_SSS"),
    h5(strong("Add additional growth platoons?")),
      uiOutput("AdvancedSS_GT5_SSS")
    
      )
     ),

    #SSS iterations
    shinyjs::hidden(wellPanel(id="panel_SSS_reps",
    h4(strong("SSS run specifications")),
    fluidRow(column(width=10,numericInput("SSS_reps", "Number of SSS iterations", value=1000,min=1, max=1000000, step=1))),
    fluidRow(column(width=10,numericInput("SSS_seed", "Seed number for draws", value=19,min=1, max=1000000, step=1)))
            )
        ),

    #wellPanel(
    shinyjs::hidden(awesomeRadio(
      inputId = "OS_choice",
      label = "Which OS?", 
      choices = c("Windows","Mac","Linux"),
      selected = "Windows",
      inline=TRUE,
      status = "warning")),
    #), 

    shinyjs::hidden(wellPanel(id="Scenario_panel",
    h4(strong("Scenario name")),
    fluidRow(column(width=8,textInput("Scenario_name", strong("Choose the name of your scenario"), value="Scenario_1"))),
    h5(p(em("Each scenario folder is saved. Changing the scenario name therefore creates a new folder of results."))),
    h5(p(em("Using different scenario names when changing data or parameter values allows easy sensitivity exploration."))),
    h5(p(strong("For Mac and Linux users, do not leave spaces in the Scenario name."))),
    
    br(),

    h4(strong("Select a folder to copy results")),
    h5(p(em("Results are copied from the 'Scenarios' folder"))),
    h5(p(em("Required to access results if using the online version"))),
    shinyDirButton(
     id="Modelout_dir",
     label="Select model folder",
     title="Choose folder to copy model scenario"
     ),
      )
      ),

      shinyjs::hidden(actionButton("run_SS",strong("Run Model"),
      width="100%",
      icon("circle-play"),
      style="font-size:120%;border:2px solid;color:#FFFFFF;background:#658D1B")),

      shinyjs::hidden(actionButton("run_SSS",strong("Run SSS"),
      width="100%",
      icon("circle-play"),
      style="font-size:120%;border:2px solid;color:#FFFFFF; background:#236192")),
  
#################### 
### Other panels ###
####################

###########################
### Likelihood profiles ###
###########################
  shinyjs::hidden(wellPanel(id="Profile_panel",
    h4(strong("Run likelihood profiles")),
    h5(em("Likelihood profiles are a powerful way to understand the information content of data and sensitivity of models to parameter uncertainty.")),
    h5(em("A likelihood profile fixes a chosen parameter to a specified set of values in a reference model. The reference model will maintain estimation of any other parameters estimated in the reference model.")),
    h5(em("For example, natural mortality (M) could be profiled over the value 0.1 to 0.3 at steps of 0.01. This creates 21 model runs that fix M to different values while keeping all other specifications the same as the reference model.")),
    h5(em("For each model run, the likelihood value and derived outputs are retained for analysis.")),
    h5(em("Any likelihood values >1.96 units from the minimum value are identify as models statistically less supported by the data. ")),
    h5(em("Plots with the profiled parameter values compared to the likelihood values and derived model outputs indicate how much information is contained in the model for the parameter and how sensitive the model is to parameters values resulting non-statistically different models.")),  
    br(),
    h5(strong("Choose folder of scenario to run profile")),
    #shinyFilesButton("LikeProf_dir", "Select scenario", "Choose folder containing model scenarios", multiple = F),
    shinyDirButton(
     id="LP_dir",
     label="Select scenario",
     title="Choose folder containing model scenarios"
     ),
    br(),
    br(),
    h4(("Individual likelihood profiles- each parameter run independently.")),  
    h5(em("If choosing multiple parameters to individually profile over, entries should be done in order of the parameters shown and separated by a comma (e.g., 0.1, 0.3).")),  
    h5(em("The range of values must also include the value of the model being used. If not, the profile will not run.")),  
    uiOutput("LikeProf_model_picks"),
#        fluidRow(selectInput("Profile_choice_choice","Parameter to profile",c("Steepness","lnR0","Natural mortality","Linf","k"))),
          fluidRow(column(width=4,textInput("Prof_Low_val", "Low value", value="")),    
                column(width=4,textInput("Prof_Hi_val", "High value", value="")),
                column(width=4,textInput("Prof_step","Sequence step", value=""))),    
        
        #br(),
        actionButton("run_Profiles",strong("Run Likelihood Profile"),
        width="100%",
        icon("circle-play"),
        style="font-size:120%;border:2px solid;color:#FFFFFF; background:#236192"),

        br(),
        br(),
        br(),
        
        h4(("Another option is to run simultaneous likelihood profiles.")),  
        h5(em("For example, Linf and k are negatively correlated and should be changing together in a profile.")),  
        h5(em("Read in .csv file with vectors of values for each parameter.")),  
        h5(em("See the 'Multi_profile_headers.csv' file for parameter header names. Erase columns not used and fill in rows with values for each likelihood run.")),  
        #  fluidRow(column(width=10,checkboxInput("multi_profile","Apply all vectors in one profile?",FALSE))),
          uiOutput("Profile_multi_values"),
        fluidRow(column(width=5,numericInput("TRP_multi_like", "Target reference point (max=1; 0= no plot)? ", value=0,min=0, max=1, step=0.001)),
                column(width=5,numericInput("LRP_multi_like","Limit reference point (max=1; 0= no plot)?", value=0,min=0, max=1, step=0.001))),    
        fluidRow(column(width=10,checkboxInput("Hess_multi_like","Include uncertainty estimation?",TRUE))),
        # fluidRow(column(width=4,numericInput("Prof_Low_val", "Low value", value=NA,min=0, max=10000, step=0.001)),    
        #         column(width=4,numericInput("Prof_Hi_val", "High value", value=NA,min=0, max=10000, step=0.001)),
        #         column(width=4,numericInput("Prof_step","Sequence step", value=NA,min=0, max=10000, step=0.001))),    

    #fluidRow(column(width=8,textInput("Profile_plot_file", strong("Label plot file"), value="Profile X"))),
    #h5(strong("Choose folder of scenario to run profile")),
    #uiOutput("LikeProf_dir_out"),
    actionButton("run_MultiProfiles",strong("Run Likelihood Multi-Profile"),
        width="100%",
        icon("circle-play"),
        style="font-size:120%;border:2px solid;color:#FFFFFF; background:#236192"),  

  )),

###############################
######## Retrospectives #######
###############################
  shinyjs::hidden(wellPanel(id="Retro_panel",
    h4(strong("Retrospective comparisons and plots")),
    h5(em("Retrospecitive modelling means sequentially removing one year of data up to a specified number of years (e.g., -10 years).")),
    h5(em("To make these comparisons, choose first the directory containing models, then the models to compare.")),
    h5(em("A time series plot of comparisons are shown in the main panel to the right for the follwing model outputs:")),  
    tags$ul(tags$li(h5(p(em("Spawning output"))))),
    tags$ul(tags$li(h5(p(em("Relative spawning output"))))),
    tags$ul(tags$li(h5(p(em("Recruitment"))))),
    h5(em("A complete compliment of comparison plots (along with the plot on the right) are saved in the chosen folder labeled 'retro'")),  
    #h5(strong(em("Retrospective Comparison Plots"))),
    br(),
    h5(strong("Choose folder containing model for retrospective analysis")),
    shinyDirButton(
      id="Retro_dir",
      label="Select folder",
      title="Choose folder containing model scenarios"
      ),
    br(),
    br(),
    #h4(strong("Comparison plot label")),
    h5(strong("Define what years to perform retrospective analysis. Input as a negative integer (e.g., -1 mean remove one year of data)")),
    fluidRow(column(width=5,numericInput("first_retro_year_in", "1st retrospective year", value=-1,min=-500, max=0, step=1)),
                column(width=5,numericInput("final_retro_year_in","Final retrospective year", value=-10,min=-500, max=0, step=1))),    
    #fluidRow(column(width=8,textInput("Sensi_comp_file", strong("Label comparison plot file"), value="Comparison 1"))),
    #br(),
    #br(),
    actionButton("run_Retro_comps",strong("Run Retrospective Comparisons"),
        width="100%",
        icon("circle-play"),
        style="font-size:120%;border:2px solid;color:#FFFFFF; background:#236192"),  
  )),


###############################
### Sensitivity comparisons ###
###############################
  shinyjs::hidden(wellPanel(id="Sensi_Comparison_panel",
    h4(strong("Sensitivity comparison plots")),
    h5(em("Comparing models offers insight into how changing data or model specification change model outputs.")),
    h5(em("To make these comparisons, choose first the directory containing models, then the models to compare.")),
    h5(em("A time series plot of comparisons are shown in the main panel to the right for the follwing model outputs:")),  
    tags$ul(tags$li(h5(p(em("Spawning output"))))),
    tags$ul(tags$li(h5(p(em("Relative spawning output"))))),
    tags$ul(tags$li(h5(p(em("Recruitment"))))),
    h5(em("A complete compliment of comparison plots (along with the plot on the right) are saved in the chosen directory in a folder labeled")),  
    #h5(strong(em("Sensitivity Comparison Plots"))),
    br(),
    h5(strong("Choose folder containing model scenarios")),
    shinyDirButton(
      id="Sensi_dir",
      label="Select directory",
      title="Choose folder containing model scenarios"
      ),
    br(),
    br(),
    #h4(strong("Comparison plot label")),
    uiOutput("Sensi_model_Ref"),
    uiOutput("Sensi_model_picks"),
    #fluidRow(column(width=10,checkboxInput("Sensi_uncertainty_choice","Include uncertainty intervals in plots?",TRUE))),
    h5(strong("Add reference points to spawning output plots. Blank input adds no line.")),
    fluidRow(column(width=5,numericInput("Sensi_TRP", "Target", value=NA,min=0, max=1, step=0.001)),
                column(width=5,numericInput("Sensi_LRP","Limit", value=NA,min=0, max=1, step=0.001))),    
    h5(strong("Sensitvitiy relative error plot features")),
    h5(strong("Add sensitivity group headers, controlling number, position, and text")),
    fluidRow(column(width=6,numericInput("SensiRE_ymin", "Minimum y-axis value", value=-1,min=-100, max=100, step=0.01)),
                column(width=6,numericInput("SensiRE_ymax","Maximum y-axis value", value=1,min=-100, max=100, step=0.01 ))),    
    fluidRow(column(width=8,textInput("SensiRE_breaks", strong("Position of vertical breaks"), value="0"))),
    fluidRow(column(width=8,textInput("SensiRE_headers", strong("Headers for relative error plots"), value=" "))),
    fluidRow(column(width=6,textInput("SensiRE_xcenter", "Vertical (x) centering of headers", value=" ")),
                column(width=6,textInput("SensiRE_ycenter","Horizontal (y) centering of headers", value=" "))),    
    fluidRow(column(width=8,textInput("Sensi_comp_file", strong("Comparison plot folder name"), value="Comparison 1"))),
    #br(),
    #br(),
    actionButton("run_Sensi_comps",strong("Run Sensitivity Comparisons"),
        width="100%",
        icon("circle-play"),
        style="font-size:120%;border:2px solid;color:#FFFFFF; background:#236192"),  
  )),


######################
### Ensemble panel ###
######################

  shinyjs::hidden(wellPanel(id="Ensemble_panel",
    h4(strong("Ensemble modelling")),
    h5(em("Ensemble modelling allows the user to combine multiple models into one weighted distribution of outputs.")),
    h5(em("User first chooses the models to combine, then how to combine them via model weights.")),
    h5(em("For example, if 3 models are chosen, weights of 1,1,1 defines equal weights.")),
    h5(em("If the middle model should have twice the weight of the others, 1,2,1 is the weighting input.")),
    br(),
    h5(strong("Choose folder containing models to combine")),
    h5(em("")),
    shinyDirButton(
      id="Ensemble_dir",
      label="Select directory",
      title="Choose folder containing models to combine"
      ),
    br(),
    br(),
    #h4(strong("Ensemble label")),
    fluidRow(column(width=8,textInput("Ensemble_file", strong("Label ensemble model file"), value="Ensemble 1"))),
    uiOutput("Ensemble_model_picks"),
    fluidRow(column(width=10,textInput("Ensemble_wts","Relative scenario weights",value=""))),
    actionButton("run_Ensemble",strong("Create Ensemble Model"),
        width="100%",
        icon("circle-play"),
        style="font-size:120%;border:2px solid;color:#FFFFFF; background:#236192"),  
  )),

#########################
### Model diagnostics ###
#########################

  shinyjs::hidden(wellPanel(id="Ensemble_panel",
    h4(strong("Model efficiency")),
    h5(em("Using ADnuts and SS-diags to improve model efficiency and performance.")),
    h5(em("This can offer speedier Bayesian approaches.")),
    br(),
    h5(strong("Choose folder containing model to evaluate")),
    h5(em("")),
    shinyDirButton(
      id="ModEff_dir",
      label="Select directory",
      title="Choose folder containing models to combine"
      ),
    br(),
    br(),
    
    fluidRow(column(width=5,numericInput("iter", "How many iterations", value=2000,min=1, max=1000000000000, step=1)),
                column(width=5,numericInput("thin","Thinning: How many iterations to keep?", value=1,min=1, max=1000000000, step=1))),
    uiOutput("ModEff_pick"),
    actionButton("run_adnuts",strong("Run Bayesian model"),
        width="100%",
        icon("circle-play"),
        style="font-size:120%;border:2px solid;color:#FFFFFF; background:#236192"),  
  )),

  ),

###########################################
###########################################
###########################################

      mainPanel(        
       tabsetPanel(id="tabs",
#         navbarPage(id="tabs",
            
          tabPanel("Data and Parameters",
              textOutput("catch_plots_label"),
              uiOutput("Ctplot_it"),
              textOutput("lt_comp_plots_label"),
              uiOutput("Ltplot_it"),
              textOutput("marginal_age_comp_plots_label"),
              uiOutput("Ageplot_it_marginal"),
              textOutput("conditional_age_comp_plots_label"),
              uiOutput("Ageplot_it_cond"),
              #plotOutput("Ageplot"),
              textOutput("index_plots_label"),
              uiOutput("Indexplot_it"),
            h4("Life history"),
            column(6,plotOutput("Mplot")),
            column(6,plotOutput("VBGFplot")),
            h6("."),
            #uiOutput("AdvancedSS_nohess_user"),
            uiOutput("Dep_plot_title"),
            uiOutput("Dep_plot_it"),
            #linebreaks(30),
            h4("Selectivity"),
            plotOutput("Selplot"),
            plotOutput("Selplot_SSS"),
            value=1),       
            
          tabPanel("SSS Model output",
            h4("Full model output is contained in the SSS_out.DMP and SSSoutput.DMP files in the specific model scenario folder."),
            h5("The SSS_out.DMP contains the prior and posterior values from the model, as well as the catch limits (Overfishing limint (OFL) and Allowable Biological Catch (ABC))."),
            h5("The SSSoutput.DMP contains a list of the complete report files for each SSS run."),
            br(),
            h5(strong("Prior and Posterior input plots")),
            plotOutput("SSS_priors_post"),
            h5(strong("Prior and Posterior growth parameter plots")),
            plotOutput("SSS_growth_priors_post"),
            h5(strong("Catch limit plots")),
            plotOutput("SSS_OFL_plot"),
            plotOutput("SSS_ABC_plot"),
            value=11),

          
          tabPanel("Model diagnostics",
            h4("Evaluate model for parameterization choices and convergence."),
            br(),
            h4("Pairs plot of slow mixing parameters"),
            br(),
            h4("Pairs plot of fast mixing parameters"),
            value=12),
          
          tabPanel("Model output",
            h4("Full model output is contained in the Report.sso file. The following reports are meant for quick examination."),
            h4("Checking model convergence. Check also fit to length composition data"),
            tableOutput("converge.grad"),
            tableOutput("converge.covar"),
            tableOutput("converge.dec"),
            tags$head(tags$style("#converge.grad{color: black;
                                 font-size: 20px;
                                 font-style: italic;
                                 }"
                         )
              ),
            tags$head(tags$style("#converge.dec{color: green;
                                 font-size: 20px;
                                 font-style: italic;
                                 }"
                         )
              ),
            br(),
            h4("Relative spawning output"),
            tableOutput("SSout_relSB_table"),
            br(),
            h4("Fishing intensity"),
            tableOutput("SSout_F_table"),
            br(),
            h4("Estimated parameters"),
            tableOutput("Parameters_table"),
            br(),
            h4("Time series"),
            tableOutput("SSout_table"),
            value=2),

          tabPanel("Jitter exploration",
            plotOutput("Jitterplot"),
            h4("Blue values indicate minimum likelihood values; red indicate values higher than the minimum."),  
            h4("Any iteration with a blue value can be used as the new best-fit (reference) model."), 
            plotOutput("Jittercompplot1"),
            h4("Comparison of spawning output among jittered models. Model 0 is the initial model; numbered models are the sequential jittered models."),
            plotOutput("Jittercompplot2"),
            h4("Comparison of relative stock status among jittered models. Model 0 is the initial model; numbered models are the sequential jittered models."),
            value=3),
          
          tabPanel("Likelihood profile",
            h4("Full likelihood profile outputs and plots can be found in the 'Profile' folder of the chosen scenario."),  
            h5("Each profile folder will be labeled with the parameter name appended."),  
            h5("Results below are from the one of the profile parameters to show what type of plots are found in the folders."),  
            plotOutput("LikeProf_plot_modout"),
            br(),
            br(),
            plotOutput("LikeProf_plot_Piner"),
            br(),
            br(),
            plotOutput("LikeProf_plot_SO"),
            br(),
            br(),
            plotOutput("LikeProf_plot_SOt_SO0"),
            br(),
            br(),
            h5("Multiple likelihood profile plot. Blue dot indicates reference model"),  
            plotOutput("LikeProf_multiplot"),
            value=4),
          
          tabPanel("Retrospectives",
            imageOutput("Retro_comp_plotSB"),            
            imageOutput("Retro_comp_plotBratio"),                      
            value=5),

          tabPanel("Sensitivity Plots",
            # uiOutput("Sensi_comp_plot"),            
            h4("Time series sensitivity plots"), 
            imageOutput("Sensi_comp_plot",width="50%"),            
            linebreaks(8),
            headerPanel(""),
            h4("Relative change (Scenario relative to reference model) sensitivity plots for 5 different metrics"), 
            h5("Unfished spawning output and terminal year spawning output measure scale"), 
            h5("Relative biomass is a stock status measure"), 
            h5("FMSY is a measure of productivity; MSY is a measure of productivity and scale"), 
            h5(paste("For more details on interpreting these plots, please see "),tags$a("Cope and Gertseva 2020",target="_blank",href="CopeandGertseva2020.pdf")),
            imageOutput("SensiRE_comp_plot",height="auto"),            
            linebreaks(8),
            headerPanel(""),
            h4("Log relative change (scenario relative to reference model) sensitivity plots for 5 different metrics"), 
            h5("Log relative change addresses the assymetry in possible relative change (infinity at the highest and 0 at the lowest)."), 
            imageOutput("SensiRElog_comp_plot",height="auto"),            
            value=6),
          
          tabPanel("Ensemble models",
            plotOutput("Ensemble_plots"),            
            value=7)
          ) 
   )
   )
)
)
