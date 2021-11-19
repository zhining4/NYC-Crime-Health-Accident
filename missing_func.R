checkcomplete <- function(temp) {
  rowNames <- colnames(temp)
  result <- vector()
  for (row in 1:nrow(temp)) {
    count = 0
    for (each in rowNames) {
      if (temp[row, each] == "FALSE") {
        count = count + 1
      }else{
        break
      }
    }
    if (count == (ncol(temp)-1)) {
      result <- c(result, row)
    }
  }
  return (result)
}

plot_missing <- function(data, percent) {
  # Handling the missing patterns when pecent is true or not
  if (percent == TRUE) {
    missing_patterns <- data.frame(is.na(data)) %>%
      group_by_all() %>%
      count(name = "count", sort = TRUE) %>%
      mutate(count = (count / nrow(data))*100) %>%
      ungroup()
  } else {
    missing_patterns <- data.frame(is.na(data)) %>%
      group_by_all() %>%
      count(name = "count", sort = TRUE) %>%
      ungroup()
  }
  ############## P1
  missing <-(colSums(is.na(data)) %>% sort(decreasing = TRUE))
  missing_val <- as.vector(missing)
  if (percent == TRUE) {
    missing_val <- missing_val / sum(missing_val) * 100
  }
  row_names <-names(missing)
  newdf<-data.frame(row_names,missing_val)
  newdf$row_names<-factor(newdf$row_names,levels=row_names)
  if (percent == TRUE) {
    p1<-ggplot(data=newdf,aes(x = row_names,y=missing_val)) +  geom_bar(stat="identity",fill="lightskyblue1")+ theme(legend.position = "none", axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) + ggtitle("Missing value patterns") + ylab("%rows missing:")  + scale_y_continuous(limits = c(0,100)) + xlab("")
  } else {
    p1<-ggplot(data=newdf,aes(x = row_names,y=missing_val)) +  geom_bar(stat="identity",fill="lightskyblue1")+ theme(legend.position = "none", axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) + ggtitle("Missing value patterns") + ylab("num rows missing:") + xlab("")
  }
  
  ############## p2
  new_missing_patterns <- missing_patterns[, c(row_names,"count")]
  completeCase <- checkcomplete(missing_patterns)
  misiing_Pattern <- seq(1,dim(missing_patterns)[1])
  data_p2 <- expand.grid(X=row_names, Y= misiing_Pattern)
  data_p2$value <- as.vector(t(as.matrix(new_missing_patterns[,-dim(new_missing_patterns)[2]])))
  data_p2$Y<-factor(data_p2$Y, levels=rev(misiing_Pattern))
  data_p2$type<-"type1"
  for (row in 1:nrow(data_p2)) {
    if (data_p2[row, "value"] == "FALSE" & (data_p2[row,"Y"] %in% completeCase == FALSE)) {
      data_p2[row, "type"] <- "type2"
    } else if (data_p2[row, "value"] == "FALSE" & (data_p2[row,"Y"] %in% completeCase == TRUE)) {
      data_p2[row, "type"] <- "type3"
    }
  }
  completeCase_x = ncol(missing_patterns) / 2
  completeCase_y = nrow(missing_patterns) - completeCase + 1
  p2<-ggplot(data_p2, aes(X, Y, fill= factor(type) ))+
    geom_tile(color = "white",
              lwd = 0.5,
              linetype = 1)+
    scale_fill_manual(values=c("type1" = "mediumpurple1", "type2" = "grey","type3" = "dark grey"))+ 
    theme(legend.position = "none", axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))+
    xlab("variable")+
    ylab("missing patterns")+
    annotate(geom="text", x=completeCase_x, y=completeCase_y, label="Complete cases")
  ############### p3
  pattern<-rev(misiing_Pattern)
  row_count<-rev(missing_patterns$count)
  data_p3<-data.frame(pattern, row_count)
  data_p3$pattern<-factor(data_p3$pattern,levels=pattern)
  if (length(completeCase) == 0) {
    data_p3$type <- "type0"
  } else {
    data_p3$type<-ifelse(data_p3$pattern==completeCase,"type1","type0")
  }
  
  if (percent == TRUE) {
    p3<-ggplot(data_p3,aes(x =pattern, y=row_count ,fill=type))+
      geom_bar(stat="identity")+
      scale_fill_manual("legend", values = c("type1" = "lightskyblue", "type0" = "lightskyblue1"))+
      theme(legend.position = "none", axis.title.y = element_blank()) +
      ylab("% row")+
      coord_flip() + scale_y_continuous(limits = c(0,100))
  } else {
    p3<-ggplot(data_p3,aes(x =pattern, y=row_count ,fill=type))+
      geom_bar(stat="identity")+
      scale_fill_manual("legend", values = c("type1" = "lightskyblue", "type0" = "lightskyblue1"))+
      theme(legend.position = "none", axis.title.y = element_blank()) +
      ylab("rows count")+
      coord_flip() 
  }
  ########## combine
  layout <- "
  AAAAAAA###
  BBBBBBBCCC
  BBBBBBBCCC
  BBBBBBBCCC
  "
  p <- p1 + p2 + p3 + plot_layout(design = layout)
  return (p)
}