load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

infile = addfile("/home/qqf/Documents/PhD-Working2/ncfile/ncep2nc/hgt.mon.mean.nc", "r")

mylev = 100
myyear = 2018

lev = infile->level

lat = infile->lat
lon = infile->lon

year=calendar_decode2(infile->time,0)
year_idx=ind(year(:,0).eq.myyear)

lev_idx = ind(lev.eq.mylev)

data = short2flt(infile->hgt)

hgt_201805 = data(year_idx(4),lev_idx,:,:)

hgt_all05 = data(4::12,lev_idx,:,:)
hgt_clim05 = dim_avg_n_Wrap(hgt_all05, 0)

hgt_anom05 = hgt_201805 - hgt_clim05
copy_VarMeta(hgt_201805, hgt_anom05)

hgt_clim05_dagpm = hgt_clim05 / 10.0
copy_VarMeta(hgt_clim05, hgt_clim05_dagpm)



res = True
res@gsnDraw=False
res@gsnFrame=False
res@gsnSpreadColors=True
res@gsnAddCyclic=True
res@gsnMaximize=True
res@gsnLeftString=""
res@gsnRightString=""

res2 = res

res@gsnPolar   = "NH"  

res@mpCenterLonF=120

res@mpDataSetName = "Earth..4"
res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
res@mpOutlineOn              = True
res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last

res@mpOutlineSpecifiers = (/"China","China:Zhejiang"/)
res@mpMaskAreaSpecifiers = (/"China","China:Zhejiang"/)
res@mpPerimOn   = True

res@cnFillOn=True
res@cnLinesOn=False
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels=(/-120,-100,-80,-60,-40,-20,-10,0,10,20,40,60,80,100,120/)
res@cnFillColors=(/4,5,6,7,8,9,10,0,0,11,12,13,14,15,16,17/)

res@lbOrientation="Vertical"

res2@cnFillOn = False
res2@cnLinesOn=True
res2@cnInfoLabelOn=False
res2@cnLevelSelectionMode = "ExplicitLevels"
res2@cnLevels=ispan(1600, 1800, 8)


wks = gsn_open_wks("eps", "May-"+mylev+"-polar")
gsn_define_colormap(wks,"BlueDarkRed18")

map = gsn_csm_contour_map_polar(wks, hgt_anom05, res)

map2 = gsn_csm_contour(wks, hgt_clim05_dagpm, res2)

overlay(map, map2)

draw(map)
frame(wks)
