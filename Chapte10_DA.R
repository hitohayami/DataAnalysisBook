ytmp=read.table('https://hastie.su.domains/ElemStatLearn/datasets/radsens.y',fill=T,header=F)
ytt=c(ytmp[1,],ytmp[2,])
yt=unlist(ytt)
yt=na.omit(yt)
y=as.vector(ytt)
(n_y=length(y))

# n_ytmp=length(ytmp)
# y=NULL
# for( i in 1:n_ytmp){
#   tmp=strsplit(ytmp[[i]],' ')
#   y_tmp=as.numeric(tmp[[1]])
#   y=c(y,y_tmp)
# }
# y=na.omit(y)
# (n_y=length(y))

xtmp=read.table('https://hastie.su.domains/ElemStatLearn/datasets/radsens.x',header=F)

# n_xtmp=length(xtmp)

# x_t=y
# for( j in 1:n_xtmp){
#   tmp=strsplit(xtmp[[j]],' ')
#   x_tmp=as.numeric(tmp[[1]])
#   x_tmp=na.omit(x_tmp)
#   x_t=rbind(x_t,x_tmp)
# }

x_t=rbind(y,xtmp)
n_X=dim(x_t)[1]
x=as.matrix(x_t[2:n_X,],ncol=n_y)

n_x=dim(x)[1]
p_V=NULL
t_V=NULL
for( j in 1:n_x){
  t_res=t.test(x[j,1:44],x[j,45:58])
  p_V=c(p_V,t_res$p.value)
  t_V=c(t_V,t_res$statistic)
}
p_Vs=sort(p_V)

xhist=hist(t_V,nclass=75,probability = TRUE,main='',xlab='t-value'
           ,xlim=c(-5,5),ylim=c(0,0.4))
curve(dt(x,df=46),from=-5,to=5,n=10000,col=1,add=TRUE,lwd=3,lty=4)
xd=density(t_V)
lines(xd$x,xd$y,col=4,lwd=3)

c(min(t_V),max(t_V))
id_sig=which(abs(t_V)>qt(0.975,df=46))
length(id_sig)
