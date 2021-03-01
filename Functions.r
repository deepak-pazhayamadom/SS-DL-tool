
gg_color_hue <- function(n) 
  {
      hues = seq(15, 375, length = n + 1)
      hcl(h = hues, l = 65, c = 100)[1:n]
  }

#current.year: Year to report output
#mod.names: List the names of the sensitivity runs
#likelihood.out=c(1,1,1): Note which likelihoods are in the model (surveys, lengths, ages)
#Sensi.RE.out="Sensi_RE_out.DMP": #Saved file of relative changes
#CI=0.95:Confidence interval box based on the reference model
#TRP.in=0.4:Target relative abundance value
#LRP.in=0.25: Limit relative abundance value
#sensi_xlab="Sensitivity scenarios" : X-axis label
#ylims.in=c(-1,2,-1,2,-1,2,-1,2,-1,2,-1,2): Y-axis label
#plot.figs=c(1,1,1,1,1,1): Which plots to make/save?
#sensi.type.breaks=NA: vertical breaks that can separate out types of sensitivities
#anno.x=NA: Vertical positioning of the sensitivity types labels
#anno.y=NA: Horizontal positioning of the sensitivity types labels
#anno.lab=NA: Sensitivity types labels


SS_Sensi_plot<-function(
            Dir,
            model.summaries,
            current.year, 
            mod.names, 
            likelihood.out=c(1,1,1), 
            Sensi.RE.out="Sensi_RE_out.DMP", 
            CI=0.95, 
            TRP.in=0.4, 
            LRP.in=0.25, 
            sensi_xlab="Sensitivity scenarios",
            ylims.in=c(-1,2,-1,2,-1,2,-1,2,-1,2,-1,2),
            plot.figs=c(1,1,1,1,1,1),
            sensi.type.breaks=NA,
            anno.x=NA,
            anno.y=NA,
            anno.lab=NA)
{
  #num.likes<-sum(likelihood.out)*2+2
  num.likes<-dim(subset(model.summaries$likelihoods_by_fleet,model==1))[1] #determine how many likelihoods components

  if(missing(mod.names)){mod.names<-paste("model ",1:model.summaries$n)}
    if(likelihood.out[1]==1)
      {
        syrvlambda_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Surv_lambda"]
        survey.lambda<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(3,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Survey_lambda")
        
        syrvlike_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Surv_like"]
        survey.like<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(syrvlike_index,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Survey_likelihood")      
      }
      else
      {
        survey.lambda<-survey.like<-data.frame(t(rep(NA,model.summaries$n+2)))
      }
    if(likelihood.out[2]==1)
      {
        Ltlambda_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Length_lambda"]
        Lt.lambda<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(Ltlambda_index,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Lt_lambda")
        Ltlike_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Length_like"]
        Lt.like<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(Ltlike_index,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Lt_likelihood")
      }
      else
      {
        Lt.lambda<-Lt.like<-data.frame(t(rep(NA,model.summaries$n+2)))
      }
    if(likelihood.out[3]==1)
      {
        Agelambda_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Age_lambda"]
        Age.lambda<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(Agelambda_index,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Age_lambda")
        Agelike_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Age_like"]
        Age.like<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(Agelike_index,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Age_likelihood")
      }
      else
      {
         Age.lambda<-Age.like<-data.frame(t(rep(NA,model.summaries$n+2)))
      }

  parms<-model.summaries$pars
  #rownames(parms)<-parms$Label
  parms<-data.frame(parms$Label,parms[,1:(dim(parms)[2]-3)],"Parameters")
  if(any(model.summaries$nsexes==1))
    {
      dev.quants<-rbind(
            model.summaries$quants[model.summaries$quants$Label=="SSB_Initial",1:(dim(model.summaries$quants)[2]-2)]/2,
            (model.summaries$quants[model.summaries$quants$Label==paste0("SSB_",current.year),1:(dim(model.summaries$quants)[2]-2)])/2,
            model.summaries$quants[model.summaries$quants$Label==paste0("Bratio_",current.year),1:(dim(model.summaries$quants)[2]-2)],
            model.summaries$quants[model.summaries$quants$Label=="Dead_Catch_SPR",1:(dim(model.summaries$quants)[2]-2)]/2,
            model.summaries$quants[model.summaries$quants$Label=="Fstd_SPR",1:(dim(model.summaries$quants)[2]-2)]
            )
      #Extract SDs for use in the ggplots
      dev.quants.SD<-c(
            model.summaries$quantsSD[model.summaries$quantsSD$Label=="SSB_Initial",1]/2,
            (model.summaries$quantsSD[model.summaries$quantsSD$Label==paste0("SSB_",current.year),1])/2,
            model.summaries$quantsSD[model.summaries$quantsSD$Label==paste0("Bratio_",current.year),1],
            model.summaries$quantsSD[model.summaries$quantsSD$Label=="Dead_Catch_SPR",1]/2,
            model.summaries$quantsSD[model.summaries$quantsSD$Label=="Fstd_SPR",1]
            )
    }
  if(any(model.summaries$nsexes==2))
    {
      dev.quants<-rbind(
            model.summaries$quants[model.summaries$quants$Label=="SSB_Initial",1:(dim(model.summaries$quants)[2]-2)],
            model.summaries$quants[model.summaries$quants$Label==paste0("SSB_",current.year),1:(dim(model.summaries$quants)[2]-2)],
            model.summaries$quants[model.summaries$quants$Label==paste0("Bratio_",current.year),1:(dim(model.summaries$quants)[2]-2)],
            model.summaries$quants[model.summaries$quants$Label=="Dead_Catch_SPR",1:(dim(model.summaries$quants)[2]-2)],
            model.summaries$quants[model.summaries$quants$Label=="Fstd_SPR",1:(dim(model.summaries$quants)[2]-2)]
            )
      #Extract SDs for use in the ggplots
      dev.quants.SD<-c(
            model.summaries$quantsSD[model.summaries$quantsSD$Label=="SSB_Initial",1],
            (model.summaries$quantsSD[model.summaries$quantsSD$Label==paste0("SSB_",current.year),1]),
            model.summaries$quantsSD[model.summaries$quantsSD$Label==paste0("Bratio_",current.year),1],
            model.summaries$quantsSD[model.summaries$quantsSD$Label=="Dead_Catch_SPR",1],
            model.summaries$quantsSD[model.summaries$quantsSD$Label=="Fstd_SPR",1]
            )
    }
  dev.quants.labs<-data.frame(c("SB0",paste0("SSB_",current.year),paste0("Bratio_",current.year),"MSY_SPR","F_SPR"),dev.quants,"Derived quantities")
  AICs<-2*model.summaries$npars+(2*as.numeric(model.summaries$likelihoods[1,1:model.summaries$n]))
  deltaAICs<-AICs-AICs[1]
  AIC.out<-data.frame(cbind(c("AIC","deltaAIC"),rbind.data.frame(AICs,deltaAICs),c("AIC")))
  colnames(AIC.out)<-colnames(survey.lambda)<-colnames(survey.like)<-colnames(Lt.lambda)<-colnames(Lt.like)<-colnames(Age.lambda)<-colnames(Age.like)<-colnames(parms)<-colnames(dev.quants.labs)<-c("Type",mod.names,"Label")
  Like.parm.quants<-rbind(AIC.out,survey.like,survey.lambda,Lt.like,Lt.lambda,Age.like,Age.lambda,parms,dev.quants.labs)  
  Like.parm.quants.table.data<-as_grouped_data(Like.parm.quants,groups=c("Label"))
  #as_flextable(Like.parm.quants.table.data)
  write.csv(Like.parm.quants.table.data,paste0(Dir,"Likes_parms_devquants_table.csv"))

#Calcualte Relative changes
dev.quants.mat<-as.matrix(dev.quants)
colnames(dev.quants.mat)<-1:dim(dev.quants.mat)[2]
rownames(dev.quants.mat)<-c("SB0",paste0("SSB_",current.year),paste0("Bratio_",current.year),"MSY_SPR","F_SPR")
#RE<-melt((as.matrix(dev.quants)-as.matrix(dev.quants)[,1])/as.matrix(dev.quants)[,1])
RE<-melt((dev.quants.mat-dev.quants.mat[,1])/dev.quants.mat[,1])[-1:-5,]
logRE<-melt(log(dev.quants.mat/dev.quants.mat[,1]))[-1:-5,]
#Get values for plots
Dev.quants.temp<-as.data.frame(cbind(rownames(dev.quants.mat),dev.quants.mat[,-1]))
colnames(Dev.quants.temp)<-c("Metric",mod.names[-1])
Dev.quants.ggplot<-data.frame(melt(Dev.quants.temp,id.vars=c("Metric")),RE[,2:3],logRE[,2:3])
colnames(Dev.quants.ggplot)<-c("Metric","Model_name","Value","Model_num_plot","RE","Model_num_plot_log","logRE")
Dev.quants.ggplot$Metric<-factor(Dev.quants.ggplot$Metric,levels=unique(Dev.quants.ggplot$Metric))
save(Dev.quants.ggplot,file=Sensi.RE.out)

#Calculate RE values for reference model boxes
CI_DQs_RE<-((dev.quants[,1]+dev.quants.SD*qnorm(CI))-dev.quants[,1])/dev.quants[,1]
TRP<-(TRP.in-dev.quants[3,1])/dev.quants[3,1]
LRP<-(LRP.in-dev.quants[3,1])/dev.quants[3,1]

logCI_DQs_RE<-log((dev.quants[,1]+dev.quants.SD*qnorm(CI))/dev.quants[,1])
logTRP<-log(TRP.in/dev.quants[3,1])
logLRP<-log(LRP.in/dev.quants[3,1])

#Plot Relative changes
four.colors<-gg_color_hue(5)
lty.in=2
if(any(is.na(sensi.type.breaks)))
  {
    lty.in=0
    sensi.type.breaks=c(1,1)
  }
if(any(is.na(anno.x)))
  {
    anno.x=c(1,1)
  }
if(any(is.na(anno.y)))
  {
    anno.y=c(1,1)
  }

if(any(is.na(anno.lab)))
  {
    anno.lab=c("","")
  }

#Begin plots
pt.dodge=0.3  
if(plot.figs[1]==1)
{
  #RE plot
  ggplot(Dev.quants.ggplot,aes(Model_num_plot,RE))+
    geom_point(aes(shape=Metric,color=Metric),position=position_dodge(pt.dodge))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[1],ymax=CI_DQs_RE[1]),fill=NA,color=four.colors[1])+ 
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[2],ymax=CI_DQs_RE[2]),fill=NA,color=four.colors[2])+ 
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[3],ymax=CI_DQs_RE[3]),fill=NA,color=four.colors[3])+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[4],ymax=CI_DQs_RE[4]),fill=NA,color=four.colors[4])+ 
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[5],ymax=CI_DQs_RE[5]),fill=NA,color=four.colors[5])+ 
    geom_hline(yintercept =c(TRP,LRP,0),lty=c(2,2,1),color=c("darkgreen","darkred","gray"))+
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot$Model_name))+
    #scale_y_continuous(limits=ylims.in[1:2])+
    coord_cartesian(ylim=ylims.in[1:2])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          legend.text.align = 0,
          panel.grid.minor = element_blank())+
    scale_shape_manual(values=c(15:18,12),
                       name ="",
                       labels = c(expression(SO[0]),
                                  as.expression(bquote('SO'[.(current.year)])),
                                  bquote(frac(SO[.(current.year)],SO[0])),
                                  expression(MSY[SPR]),
                                  expression(F[SPR])))+
    scale_color_manual(values=four.colors[1:5],
                       name ="",
                       labels = c(expression(SO[0]),
                                  as.expression(bquote('SO'[.(current.year)])),
                                  bquote(frac(SO[.(current.year)],SO[0])),
                                  expression(MSY[SPR]),
                                  expression(F[SPR])))+
    labs(x = sensi_xlab,y = "Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    annotate("text",x=c((model.summaries$n+2),(model.summaries$n+2)),y=c(TRP+0.03,LRP-0.03),label=c("TRP","LRP"),size=c(3,3),color=c("darkgreen","darkred"))+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_REplot_all.png"))
  
  #log plot
  ggplot(Dev.quants.ggplot,aes(Model_num_plot,logRE))+
    geom_point(aes(shape=Metric,color=Metric),position=position_dodge(pt.dodge))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[1],ymax=logCI_DQs_RE[1]),fill=NA,color=four.colors[1])+ 
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[2],ymax=logCI_DQs_RE[2]),fill=NA,color=four.colors[2])+ 
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[3],ymax=logCI_DQs_RE[3]),fill=NA,color=four.colors[3])+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[4],ymax=logCI_DQs_RE[4]),fill=NA,color=four.colors[4])+ 
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[5],ymax=logCI_DQs_RE[5]),fill=NA,color=four.colors[5])+ 
    geom_hline(yintercept =c(logTRP,logLRP,0),lty=c(2,2,1),color=c("darkgreen","darkred","gray"))+
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot$Model_name))+
    #scale_y_continuous(limits=ylims.in[1:2])+
    coord_cartesian(ylim=ylims.in[1:2])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),legend.text.align = 0,panel.grid.minor = element_blank())+
    scale_shape_manual(values=c(15:18,12),
                       name ="",
                       labels = c(expression(SO[0]),
                                  as.expression(bquote('SO'[.(current.year)])),
                                  bquote(frac(SO[.(current.year)],SO[0])),
                                  expression(MSY[SPR]),
                                  expression(F[SPR])))+
    scale_color_manual(values=four.colors[1:5],
                       name ="",
                       labels = c(expression(SO[0]),
                                  as.expression(bquote('SO'[.(current.year)])),
                                  bquote(frac(SO[.(current.year)],SO[0])),
                                  expression(MSY[SPR]),
                                  expression(F[SPR])))+
    labs(x = sensi_xlab,y = "Log relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    annotate("text",x=c((model.summaries$n+2),(model.summaries$n+2)),y=c(logTRP+0.03,logLRP-0.03),label=c("TRP","LRP"),size=c(3,3),color=c("darkgreen","darkred"))+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_logREplot_all.png"))
}

if(plot.figs[1]==1)
{
  #RE plots
  Dev.quants.ggplot.SBs<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[1]| Metric == unique(Dev.quants.ggplot$Metric)[2])
  p1<-ggplot(Dev.quants.ggplot.SBs,aes(Model_num_plot,RE))+
    geom_point(aes(shape=Metric,color=Metric),position=position_dodge(pt.dodge))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[1],ymax=CI_DQs_RE[1]),fill=NA,color=four.colors[1])+ 
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[2],ymax=CI_DQs_RE[2]),fill=NA,color=four.colors[2])+ 
    scale_x_continuous(breaks = 2:(model.summaries$n))+
    #scale_y_continuous(limits=ylims.in[1:2])+
    coord_cartesian(ylim=ylims.in[1:2])+ 
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          panel.grid.minor = element_blank())+
    scale_shape_manual(values=c(16,17),
                       name ="",
                       labels = c(expression(SO[0]),
                                  as.expression(bquote('SO'[.(current.year)]))))+
    scale_color_manual(values=four.colors[1:2],
                       name ="",
                       labels = c(expression(SO[0]),
                                  as.expression(bquote('SO'[.(current.year)]))))+
    theme(legend.text.align = 0)+
    labs(x = " ",y = " ")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_hline(yintercept =0,lwd=0.5,color="gray")+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  
  Dev.quants.ggplot.Dep<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[3])
  
  p2<-ggplot(Dev.quants.ggplot.Dep,aes(Model_num_plot,RE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[3],ymax=CI_DQs_RE[3]),fill=NA,color=four.colors[3])+ 
    scale_x_continuous(breaks = 2:(model.summaries$n))+
    #scale_y_continuous(limits=ylims.in[7:8])+
    coord_cartesian(ylim=ylims.in[7:8])+ 
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          panel.grid.minor = element_blank())+
    theme(legend.text.align = 0)+
    labs(x = " ",y = "Relative change")+
    scale_colour_manual(values = four.colors[3], 
                        name ="",
                        labels = as.expression(bquote(frac(SO[.(current.year)],SO[0]))))+
    annotate("text",x=c((model.summaries$n+1),(model.summaries$n+1)),y=c(TRP+0.1,LRP-0.1),label=c("TRP","LRP"),size=c(3,3),color=c("darkgreen","darkred"))+
    geom_hline(yintercept =c(TRP,LRP,0),lty=c(3,3,1),lwd=c(0.5,0.5,0.5),color=c("darkgreen","darkred","gray"))+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  
  Dev.quants.ggplot.MSY_FMSY<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[4]| Metric == unique(Dev.quants.ggplot$Metric)[5])
  p3<-ggplot(Dev.quants.ggplot.MSY_FMSY,aes(Model_num_plot,RE,group=Metric))+
    geom_point(aes(shape=Metric,color=Metric),position=position_dodge(pt.dodge))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[4],ymax=CI_DQs_RE[4]),fill=NA,color=four.colors[4])+ 
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[5],ymax=CI_DQs_RE[5]),fill=NA,color=four.colors[5])+ 
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot$Model_name))+
    #scale_y_continuous(limits=ylims.in[9:10])+
    coord_cartesian(ylim=ylims.in[9:10])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          legend.text.align = 0,
          panel.grid.minor = element_blank())+
    #          legend.text=element_text(size=rel(1)))+
    scale_shape_manual(values=c(16,17),
                       name ="",
                       labels = expression(MSY,F[SPR]))+
    scale_color_manual(values=four.colors[4:5],
                       name ="",
                       labels = expression(MSY,F[SPR]))+
    labs(x = sensi_xlab,y = "")+
    guides(fill=FALSE)+
    #annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_hline(yintercept =0,lwd=0.5,color="gray")+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  
  #p4<-grid.arrange(p1,p2,p3,heights=c(5,5,8))  
  p4<-ggarrange(p1,p2,p3,nrow=3,ncol=1,align="v",heights=c(5,5,8))  
  ggsave(paste0(Dir,"Sensi_REplot_SB_Dep_F_MSY.png"),p4)
  
  #Log plots
  Dev.quants.ggplot.SBs<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[1]| Metric == unique(Dev.quants.ggplot$Metric)[2])
  p1<-ggplot(Dev.quants.ggplot.SBs,aes(Model_num_plot,logRE))+
    geom_point(aes(shape=Metric,color=Metric),position=position_dodge(pt.dodge))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[1],ymax=logCI_DQs_RE[1]),fill=NA,color=four.colors[1])+ 
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[2],ymax=logCI_DQs_RE[2]),fill=NA,color=four.colors[2])+ 
    scale_x_continuous(breaks = 2:(model.summaries$n))+
    #scale_y_continuous(limits=ylims.in[1:2])+
    coord_cartesian(ylim=ylims.in[1:2])+ 
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          panel.grid.minor = element_blank())+
    scale_shape_manual(values=c(16,17),
                       name ="",
                       labels = c(expression(SO[0]),
                                  as.expression(bquote('SO'[.(current.year)]))))+
    scale_color_manual(values=four.colors[1:2],
                       name ="",
                       labels = c(expression(SO[0]),
                                  as.expression(bquote('SO'[.(current.year)]))))+
    theme(legend.text.align = 0)+
    labs(x = " ",y = " ")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_hline(yintercept =0,lwd=0.5,color="gray")+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  
  Dev.quants.ggplot.Dep<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[3])
  p2<-ggplot(Dev.quants.ggplot.Dep,aes(Model_num_plot,logRE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[3],ymax=logCI_DQs_RE[3]),fill=NA,color=four.colors[3])+ 
    scale_x_continuous(breaks = 2:(model.summaries$n))+
    #scale_y_continuous(limits=ylims.in[7:8])+
    coord_cartesian(ylim=ylims.in[7:8])+ 
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          panel.grid.minor = element_blank())+
    theme(legend.text.align = 0)+
    labs(x = " ",y = "Log relative change")+
    scale_colour_manual(values = four.colors[3], 
                        name ="",
                        labels = as.expression(bquote(frac(SO[.(current.year)],SO[0]))))+
    annotate("text",x=c((model.summaries$n+1),(model.summaries$n+1)),y=c(logTRP+0.08,logLRP-0.08),label=c("TRP","LRP"),size=c(3,3),color=c("darkgreen","darkred"))+
    geom_hline(yintercept =c(logTRP,logLRP,0),lty=c(3,3,1),lwd=c(0.5,0.5,0.5),color=c("darkgreen","darkred","gray"))+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  
  Dev.quants.ggplot.MSY_FMSY<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[4]| Metric == unique(Dev.quants.ggplot$Metric)[5])
  p3<-ggplot(Dev.quants.ggplot.MSY_FMSY,aes(Model_num_plot,logRE,group=Metric))+
    geom_point(aes(shape=Metric,color=Metric),position=position_dodge(pt.dodge))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[4],ymax=logCI_DQs_RE[4]),fill=NA,color=four.colors[4])+ 
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[5],ymax=logCI_DQs_RE[5]),fill=NA,color=four.colors[5])+ 
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot$Model_name))+
    #scale_y_continuous(limits=ylims.in[9:10])+
    coord_cartesian(ylim=ylims.in[9:10])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          legend.text.align = 0,
          panel.grid.minor = element_blank())+
    #          legend.text=element_text(size=7.5))+
    scale_shape_manual(values=c(16,17),
                       name ="",
                       labels = expression(MSY[SPR],F[SPR]))+
    scale_color_manual(values=four.colors[4:5],
                       name ="",
                       labels = expression(MSY[SPR],F[SPR]))+
    labs(x = sensi_xlab,y = "")+
    guides(fill=FALSE)+
    #annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_hline(yintercept =0,lwd=0.5,color="gray")+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  
  p4<-ggarrange(p1,p2,p3,nrow=3,ncol=1,align="v",heights=c(5,5,8))  
  #p4<-grid.arrange(p1,p2,p3,heights=c(5,5,8))  
  ggsave(paste0(Dir,"Sensi_logREplot_SB_Dep_F_MSY.png"),p4)
  
}

if(plot.figs[2]==1)
{
  #RE plot
  Dev.quants.ggplot.SB0<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[1])
  ggplot(Dev.quants.ggplot.SB0,aes(Model_num_plot,RE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[1],ymax=CI_DQs_RE[1]),fill=NA,color=four.colors[1])+ 
    geom_hline(yintercept =0,lty=1,color="gray")+
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot.SB0$Model_name))+
    #scale_y_continuous(limits=ylims.in[3:4])+
    coord_cartesian(ylim=ylims.in[3:4])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          legend.text.align = 0,
          panel.grid.minor = element_blank())+
    scale_colour_manual(values = four.colors[1], 
                        name ="",
                        labels = expression(SO[0]))+
    labs(x = sensi_xlab,y = "Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_REplot_SO_0.png"))
  
  #Log plot
  Dev.quants.ggplot.SB0<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[1])
  ggplot(Dev.quants.ggplot.SB0,aes(Model_num_plot,logRE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[1],ymax=logCI_DQs_RE[1]),fill=NA,color=four.colors[1])+ 
    geom_hline(yintercept =0,lty=1,color="gray")+
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot.SB0$Model_name))+
    #scale_y_continuous(limits=ylims.in[3:4])+
    coord_cartesian(ylim=ylims.in[3:4])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          legend.text.align = 0,
          panel.grid.minor = element_blank())+
    scale_colour_manual(values = four.colors[1], 
                        name ="",
                        labels = expression(SO[0]))+
    labs(x = sensi_xlab,y = "Log Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_logREplot_SO_0.png"))
}

if(plot.figs[3]==1)
{
  #RE plots  
  Dev.quants.ggplot.SBt<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[2])
  ggplot(Dev.quants.ggplot.SBt,aes(Model_num_plot,RE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[2],ymax=CI_DQs_RE[2]),fill=NA,color=four.colors[2])+ 
    geom_hline(yintercept =0,lty=1,color="gray")+
    scale_x_continuous(breaks = 2:(model.summaries$n),minor_breaks=NULL,labels=unique(Dev.quants.ggplot.SBt$Model_name))+
    #scale_y_continuous(limits=ylims.in[5:6])+
    coord_cartesian(ylim=ylims.in[5:6])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          #panel.grid.minor = element_blank(),
          legend.text.align = 0)+
    scale_colour_manual(values = four.colors[2], 
                        name ="",
                        labels = as.expression(bquote('SO'[.(current.year)])))+
    labs(x = sensi_xlab,y = "Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_REplot_SOcurrent.png"))
  
  #Log plots  
  Dev.quants.ggplot.SBt<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[2])
  ggplot(Dev.quants.ggplot.SBt,aes(Model_num_plot,logRE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[2],ymax=logCI_DQs_RE[2]),fill=NA,color=four.colors[2])+ 
    geom_hline(yintercept =0,lty=1,color="gray")+
    scale_x_continuous(breaks = 2:(model.summaries$n),minor_breaks=NULL,labels=unique(Dev.quants.ggplot.SBt$Model_name))+
    #scale_y_continuous(limits=ylims.in[5:6])+
    coord_cartesian(ylim=ylims.in[5:6])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          #panel.grid.minor = element_blank(),
          legend.text.align = 0)+
    scale_colour_manual(values = four.colors[2], 
                        name ="",
                        labels = as.expression(bquote('SO'[.(current.year)])))+
    labs(x = sensi_xlab,y = "Log Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_logREplot_SOcurrent.png"))
}

if(plot.figs[4]==1)
{
  #RE plots
  Dev.quants.ggplot.Dep<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[3])
  ggplot(Dev.quants.ggplot.Dep,aes(Model_num_plot,RE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[3],ymax=CI_DQs_RE[3]),fill=NA,color=four.colors[3])+ 
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot.Dep$Model_name))+
    #scale_y_continuous(limits=ylims.in[7:8])+
    coord_cartesian(ylim=ylims.in[7:8])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          legend.text.align = 0,
          panel.grid.minor = element_blank())+
    labs(x = " ",y = "Relative change")+
    scale_colour_manual(values = four.colors[3], 
                        name ="",
                        labels = as.expression(bquote(frac(SO[.(current.year)],SO[0]))))+
    annotate("text",x=c((model.summaries$n+2),(model.summaries$n+2)),y=c(TRP+0.03,LRP-0.03),label=c("TRP","LRP"),size=c(3,3),color=c("darkgreen","darkred"))+
    labs(x = sensi_xlab,y = "Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_hline(yintercept =c(TRP,LRP,0),lty=c(3,3,1),lwd=c(0.5,0.5,0.5),color=c("darkgreen","darkred","gray"))+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_REplot_status.png"))
  
  #Log plots
  Dev.quants.ggplot.Dep<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[3])
  ggplot(Dev.quants.ggplot.Dep,aes(Model_num_plot,logRE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[3],ymax=logCI_DQs_RE[3]),fill=NA,color=four.colors[3])+ 
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot.Dep$Model_name))+
    #scale_y_continuous(limits=ylims.in[7:8])+
    coord_cartesian(ylim=ylims.in[7:8])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          legend.text.align = 0,
          panel.grid.minor = element_blank())+
    labs(x = " ",y = "Relative change")+
    scale_colour_manual(values = four.colors[3], 
                        name ="",
                        labels = as.expression(bquote(frac(SO[.(current.year)],SO[0]))))+
    annotate("text",x=c((model.summaries$n+2),(model.summaries$n+2)),y=c(logTRP+0.03,logLRP-0.03),label=c("TRP","LRP"),size=c(3,3),color=c("darkgreen","darkred"))+
    labs(x = sensi_xlab,y = "Log Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_hline(yintercept =c(logTRP,logLRP,0),lty=c(3,3,1),lwd=c(0.5,0.5,0.5),color=c("darkgreen","darkred","gray"))+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_logREplot_status.png"))
}

if(plot.figs[5]==1)
{
  #RE plots
  Dev.quants.ggplot.MSY<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[4])
  ggplot(Dev.quants.ggplot.MSY,aes(Model_num_plot,RE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[4],ymax=CI_DQs_RE[4]),fill=NA,color=four.colors[4])+ 
    geom_hline(yintercept =0,lty=1,color="gray")+
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot.MSY$Model_name))+
    #scale_y_continuous(limits=ylims.in[9:10])+
    coord_cartesian(ylim=ylims.in[9:10])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          panel.grid.minor = element_blank())+
    scale_color_manual(values=four.colors[4],
                       name ="",
                       labels = expression(MSY[SPR]))+
    labs(x = sensi_xlab,y = "Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_REplot_MSY.png"))
  #Log plots
  Dev.quants.ggplot.MSY<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[4])
  ggplot(Dev.quants.ggplot.MSY,aes(Model_num_plot,logRE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[4],ymax=logCI_DQs_RE[4]),fill=NA,color=four.colors[4])+ 
    geom_hline(yintercept =0,lty=1,color="gray")+
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot.MSY$Model_name))+
    #scale_y_continuous(limits=ylims.in[9:10])+
    coord_cartesian(ylim=ylims.in[9:10])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          panel.grid.minor = element_blank())+
    scale_color_manual(values=four.colors[4],
                       name ="",
                       labels = expression(MSY[SPR]))+
    labs(x = sensi_xlab,y = "Log Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_logREplot_MSY.png"))
}

if(plot.figs[6]==1)
{
  #RE plots
  Dev.quants.ggplot.FMSY<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[5])
  ggplot(Dev.quants.ggplot.FMSY,aes(Model_num_plot,RE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[5],ymax=CI_DQs_RE[5]),fill=NA,color=four.colors[5])+ 
    geom_hline(yintercept =0,lty=1,color="gray")+
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot.FMSY$Model_name))+
    #scale_y_continuous(limits=ylims.in[11:12])+
    coord_cartesian(ylim=ylims.in[11:12])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          panel.grid.minor = element_blank())+
    scale_color_manual(values=four.colors[5],
                       name ="",
                       labels = expression(F[SPR]))+
    labs(x = sensi_xlab,y = "Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_REplot_FMSY.png"))
  
  #RE plots
  Dev.quants.ggplot.FMSY<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[5])
  ggplot(Dev.quants.ggplot.FMSY,aes(Model_num_plot,logRE))+
    geom_point(aes(color=Metric))+
    geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-logCI_DQs_RE[5],ymax=logCI_DQs_RE[5]),fill=NA,color=four.colors[5])+ 
    geom_hline(yintercept =0,lty=1,color="gray")+
    scale_x_continuous(breaks = 2:(model.summaries$n),labels=unique(Dev.quants.ggplot.FMSY$Model_name))+
    #scale_y_continuous(limits=ylims.in[11:12])+
    coord_cartesian(ylim=ylims.in[11:12])+ 
    theme(axis.text.x = element_text(angle=45,hjust=1,vjust=1),
          panel.grid.minor = element_blank())+
    scale_color_manual(values=four.colors[5],
                       name ="",
                       labels = expression(F[SPR]))+
    labs(x = sensi_xlab,y = "Log Relative change")+
    annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
    geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave(paste0(Dir,"Sensi_logREplot_FMSY.png"))
}
}