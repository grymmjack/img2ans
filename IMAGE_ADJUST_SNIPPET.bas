' Example usage in your pipeline (after scaling, before ConvertImageToAnsi$):
' '$INCLUDE:'core/image_ops.bi'
' '$INCLUDE:'core/image_ops.bas'
'
' DIM brightness%: brightness% = 20          ' -255..+255
' DIM contrast%:   contrast%   = 15          ' -100..+100
' DIM levels%:     levels%     = 5           ' posterize buckets (e.g., 5 → step 51)
' CALL AdjustImageInPlace(scaled&, brightness%, contrast%, levels%)
