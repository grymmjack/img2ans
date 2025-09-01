# 🎨 NEW DITHERING ALGORITHMS ADDED TO IMG2PAL! 🎨

## What's New?

We've expanded IMG2PAL from 15 to **23 dithering algorithms**! Here are the 8 exciting new additions:

### 🌟 **Advanced Error Diffusion Algorithms**

**15. False Floyd-Steinberg** 
- ⚡ Faster than regular Floyd-Steinberg
- 📐 Simplified 2-pixel error distribution
- 🎯 Perfect for when you need speed over quality

**16. Fan Error Diffusion**
- 🏆 Modern, high-quality algorithm  
- ✨ Enhanced Floyd-Steinberg with better distribution
- 🎨 Excellent for complex images with fine details

**17. Stevenson-Arce**
- 🧠 Advanced academic algorithm
- 🔬 Complex 5x3 kernel with 157-part distribution
- 💎 Highest quality error diffusion available

**18. Two-Row Sierra** 
- 🏔️ Extended version of Sierra algorithm
- ⚖️ Perfect balance of quality and performance
- 📊 Enhanced error propagation pattern

**19. Shiau-Fan**
- 🆕 Modern error diffusion variant
- 🌿 Optimized for natural/photographic images  
- ⚙️ Uses efficient power-of-2 fractions

### 🎲 **Advanced Pattern & Noise Algorithms**

**20. Ordered 16x16 Bayer**
- 🖼️ Finest ordered dithering available
- 🌊 Creates incredibly smooth gradients
- 📐 16x16 matrix for maximum detail

**21. Interleaved Gradient Noise (IGN)**
- 🎯 State-of-the-art noise algorithm
- 📈 Mathematical gradient function
- 🚫 No pattern artifacts, perfect for photos

**22. Spiral Dithering**
- 🌀 Unique artistic spiral patterns
- 🎨 Creates mesmerizing visual effects
- ✨ Perfect for creative/decorative work

## 🎮 How to Use

- Press `<` and `>` (or `,` and `.`) to cycle through all 23 methods
- Press `+` and `-` to adjust dithering intensity (0% to 200%)
- Press `D` to toggle dithering on/off
- Current method name is shown in the status line

## 🏆 Algorithm Recommendations

**🏃‍♂️ Need Speed?** → False Floyd-Steinberg (15), Sierra Lite (9)
**🖼️ Best Quality?** → Fan (16), Stevenson-Arce (17), Stucki (6) 
**📷 For Photos?** → IGN (21), Blue Noise (12), Floyd-Steinberg (4)
**🎨 Artistic Effects?** → Spiral (22), Halftone (14), Atkinson (10)
**🌊 Smooth Gradients?** → 16x16 Bayer (20), JJN (5), Two-Row Sierra (18)
**👾 Retro/Pixel Art?** → 2x2 Bayer (1), 4x4 Bayer (2), Clustered Dot (13)

## 🔬 Technical Details

All algorithms feature:
- ⚡ Optimized performance with palette caching
- 📊 Progress indicators for large images  
- 🎚️ Intensity control (0-200%)
- 🛡️ Proper value clamping and error handling
- 💾 Memory-efficient implementations

## 🎉 Have Fun Exploring!

With 23 different dithering algorithms, you now have an incredible toolkit for converting images to palettes. Each algorithm has its own character and optimal use cases. Experiment with different methods and intensity levels to find the perfect look for your images!

Happy dithering! 🎨✨
