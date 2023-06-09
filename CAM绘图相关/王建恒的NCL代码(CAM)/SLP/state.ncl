load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;***********************************************************
;********directionary (need to be change)********
;***********************************************************
	name	= (/"case1","case2","case3"/)

	dir	= "/home/wjh/arctic-seaice/output"	

in1=addfile(dir+"/case1/PSL.nc","r")
in2=addfile(dir+"/case2/PSL.nc","r")
in3=addfile(dir+"/case3/PSL.nc","r")
;***********************************************************
;*****read month************************************
;***********************************************************

dec1=in1->PSL(11::12,:,:)
dec2=in2->PSL(11::12,:,:)
dec3=in3->PSL(11::12,:,:)
jan1=in1->PSL(0::12,:,:)
jan2=in2->PSL(0::12,:,:)
jan3=in3->PSL(0::12,:,:)
feb1=in1->PSL(1::12,:,:)
feb2=in2->PSL(1::12,:,:)
feb3=in3->PSL(1::12,:,:)

;***********************************************************
;******calculate season average if need:Temp1=(DEC1+JAN1+FEB1)/3.0********
;***********************************************************

Temp1=	dim_avg_n((dec1+jan1+feb1)/3.0,0)
Temp2=	dim_avg_n((dec2+jan2+feb2)/3.0,0)
Temp3=	dim_avg_n((dec3+jan3+feb3)/3.0,0)

x=in1->PSL(0,:,:)

	dim	= dimsizes(Temp1)

	winter	= new((/3,dim(0),dim(1)/),float)

	winter(0,:,:)	= Temp1/100.
	winter(1,:,:)	= Temp2/100.
	winter(2,:,:)	= Temp3/100.

do n = 0,2

copy_VarCoords(x,winter(n,:,:))

;********wks**********************
wks = gsn_open_wks("eps",name(n))
gsn_define_colormap(wks,"gui_default")
;********dif res*************************
res=True

res@tiMainString = "PSL in winter"
res@gsnLeftString = ""
res@gsnCenterString = name(n)
res@gsnRightString = "hPa"
res@cnLevelSelectionMode = "ManualLevels"
;res@cnMinLevelValF=-160
;res@cnMaxLevelValF= 160
;res@cnLevelSpacingF = 1
res@cnFillOn = True
res@gsnSpreadColors = True
res@gsnPolar    = "NH"
res@gsnDraw=False
res@gsnFrame=False 
res@mpMinLatF = 30
res@gsnDraw             = True       ; Do not draw plot
res@gsnFrame            = True       ; Do not advance frome


plot	= gsn_csm_contour_map_polar(wks,winter(n,:,:),res)

end do

end





