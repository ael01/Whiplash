# Whiplash
These data and code are for reproducing the main analyses in "Weathering the storm: precipitation whiplash has limited effects on agricultural production and pesticide use in California" (Ashley E. Larsen, Daniel Sousa, Amy Quandt, Andrew J. MacDonald). 

Data Dictionary:
year – Year of growing permit
permit – Grower ID
trsFields – Public Land Survey Section (Township Range Section) of field, reported by grower
HaFlood23 – Maximum area (ha) flooded in 2023, extracted to field. 
commShort – commodity, removing details beyond commodity type that are self-reported in 
some years (parsed on –).  
rcommShort – Numeric code for commShort.
FieldSizeHa  – Permitted field size, corrected for multicropped fields (see text).
FarmSizeHa- Farm size in Ha
Water23  – binary variable equal to one if area flooded in 2023 is greater than zero.
MonthActive  – First month of active growing permit
TotActiveHaK – Total area of cropland by first month-year of active growing permit. For summary stats figure (Figure S1).
Month_wOffset  – First month of active growing permit, with small offset for plotting summary stats figure (Figure S1).
MonthMinWater23  –  First month field has water present in 2023. Used to subset the sample before and after executive order (See text)
KgAIPest  – Kg of active ingredients for all pesticides
KgHaAIPest  – Kg of active ingredients for all pesticides scaled by field size
KgHaAIInsectOnly  – Kg of active ingredients for insecticides (only) scaled by field size
KgHaAIHerbOnly  – Kg of active ingredients for herbicides (only) scaled by field size
KgHaAIInsectFung  – Kg of active ingredients for insect/fungicide dual action pesticides scaled by field size
KgHaAIFungOnly  – Kg of active ingredients for fungicides (only) scaled by field size
ihsKgHaAIInsectOnly100  – Inverse hyperbolic sine transformation of KgHaAIInsectOnly, after pre-multiplying by 100 (see text)
ihsKgHaAIHerbOnly100  – Inverse hyperbolic sine transformation of KgHaAIHerbOnly, after pre-multiplying by 100 (see text)
ihsKgHaAIInsectFung100  – Inverse hyperbolic sine transformation of KgHaAIInsectFung, after pre-multiplying by 100 (see text)
ihsKgHaAIFungOnly100  – Inverse hyperbolic sine transformation of KgHaAIFungOnly, after pre-multiplying by 100 (see text)
![image](https://github.com/user-attachments/assets/3bc30968-a9d6-475c-bdef-8e6252247301)

