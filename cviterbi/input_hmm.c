#include <float.h>
#include <stdlib.h>

#include "model.h"

struct HMM *input_hmm = &(struct HMM){9, {
    { 0.7864, 1.08174, 1.58224, 0.037809999999999996, 3.29406, 0.0, DBL_MAX,
    { 2.61196, 4.43481, 2.8614800000000002, 2.75135, 3.2699, 2.8758, 3.69681, 2.78467, 2.68719, 2.51974, 3.70525, 3.0584, 3.33683, 3.1853, 3.01309, 2.5621, 2.78721, 2.61676, 4.19837, 3.22308 },
    { 2.68656, 4.42543, 2.77442, 2.73222, 3.46583, 2.40778, 3.72813, 3.29544, 2.67647, 2.6921299999999997, 4.24342, 2.90092, 2.7391, 3.1812, 2.89692, 2.38011, 2.77326, 2.98498, 4.57862, 3.60949 }
    }
    , 
    { 1.30932, 0.32463000000000003, 4.93318, 1.75061, 0.19075999999999999, 0.34469, 1.23251,
    { 3.911, 5.07231, 4.89593, 4.64269, 0.86951, 4.6098, 3.57587, 3.5404, 4.47001, 2.8223700000000003, 4.12141, 4.26815, 4.90493, 4.3569700000000005, 4.4388, 3.99423, 4.12852, 3.48249, 3.6905799999999997, 1.39795 },
    { 2.68623, 4.4223, 2.77524, 2.73128, 3.46358, 2.40517, 3.72499, 3.29359, 2.67745, 2.69359, 4.24694, 2.90351, 2.73744, 3.18151, 2.89805, 2.3784, 2.77524, 2.98523, 4.58482, 3.61508 }
    }
    , 
    { 0.42277000000000003, 1.08174, 5.15601, 0.09346, 2.41657, 0.48575999999999997, 0.9551000000000001,
    { 2.71231, 4.89867, 3.02572, 1.91872, 4.1468, 3.50442, 3.75326, 3.57316, 2.56399, 3.18074, 4.00059, 3.05334, 3.92249, 2.91151, 3.02179, 2.25778, 2.1098, 3.24875, 5.41941, 2.85771 },
    { 2.6880100000000002, 4.42408, 2.77553, 2.73018, 3.46537, 2.40485, 3.72282, 3.29537, 2.67652, 2.69177, 4.24221, 2.90444, 2.73706, 3.18149, 2.89763, 2.38019, 2.77581, 2.98422, 4.57747, 3.61686 }
    }
    , 
    { 4.43366, 0.01779, 5.15601, 0.7725500000000001, 0.61958, 0.48575999999999997, 0.9551000000000001,
    { 2.83776, 4.97355, 1.95977, 2.61427, 4.04156, 3.5457099999999997, 3.8594, 3.6739100000000002, 2.74445, 3.27482, 4.12809, 3.12864, 2.20424, 3.06418, 3.20013, 2.87439, 3.0944, 3.35808, 2.18299, 3.9902100000000003 },
    { 2.6861800000000002, 4.42225, 2.7751900000000003, 2.73123, 3.46354, 2.40513, 3.72494, 3.29354, 2.67741, 2.69355, 4.2469, 2.90347, 2.73739, 3.18146, 2.89801, 2.37887, 2.7751900000000003, 2.98518, 4.58477, 3.61503 }
    }
    , 
    { 0.7864, 0.61849, 5.15601, 0.54438, 0.86798, 0.48575999999999997, 0.9551000000000001,
    { 2.55974, 4.43496, 3.67296, 3.2268, 4.06912, 3.3677, 4.22547, 3.35969, 3.20277, 3.13099, 4.01298, 3.50039, 2.05854, 3.51273, 3.5430200000000003, 1.63601, 2.95317, 1.83011, 5.47931, 4.24476 },
    { 2.68643, 4.4225, 2.77378, 2.73149, 3.46379, 2.40485, 3.72288, 3.29379, 2.67766, 2.6938, 4.2471499999999995, 2.90372, 2.73765, 3.18172, 2.89826, 2.37912, 2.77545, 2.98449, 4.58502, 3.6152800000000003 }
    }
    , 
    { 4.43366, 0.01779, 5.15601, 0.7725500000000001, 0.61958, 0.48575999999999997, 0.9551000000000001,
    { 2.90761, 5.34202, 2.85374, 1.68426, 4.69586, 3.5357700000000003, 3.7646100000000002, 4.15505, 2.42691, 3.63104, 4.41812, 2.0119, 3.98562, 2.88533, 1.92809, 2.86075, 3.1390000000000002, 3.74841, 5.74849, 4.37868 },
    { 2.6861800000000002, 4.42225, 2.7751900000000003, 2.73123, 3.46354, 2.40513, 3.72494, 3.29354, 2.67741, 2.69355, 4.2469, 2.90347, 2.73739, 3.18146, 2.89801, 2.37887, 2.7751900000000003, 2.98518, 4.58477, 3.61503 }
    }
    , 
    { 1.3811900000000001, 0.29712, 5.15601, 0.33242, 1.26296, 0.48575999999999997, 0.9551000000000001,
    { 1.95109, 4.6272400000000005, 3.39396, 2.86368, 2.27738, 3.61009, 3.88574, 3.17982, 1.8516400000000002, 2.863, 3.76559, 3.30353, 4.03195, 3.14268, 3.11144, 2.88172, 2.99083, 2.93065, 5.16799, 3.86477 },
    { 2.6864, 4.42247, 2.77542, 2.7305900000000003, 3.46376, 2.40535, 3.72517, 3.29376, 2.6776299999999997, 2.6937699999999998, 4.24712, 2.90165, 2.7376199999999997, 3.18034, 2.89823, 2.37909, 2.77542, 2.98541, 4.58499, 3.61525 }
    }
    , 
    { 4.43366, 0.01779, 5.15601, 0.7725500000000001, 0.61958, 0.48575999999999997, 0.9551000000000001,
    { 1.91927, 4.46859, 4.67527, 4.12702, 3.5011200000000002, 4.27756, 4.70627, 1.46485, 3.9996, 1.53841, 3.37299, 4.32743, 4.61861, 4.219, 4.16948, 3.61315, 3.3254, 2.06179, 5.28032, 4.11266 },
    { 2.6861800000000002, 4.42225, 2.7751900000000003, 2.73123, 3.46354, 2.40513, 3.72494, 3.29354, 2.67741, 2.69355, 4.2469, 2.90347, 2.73739, 3.18146, 2.89801, 2.37887, 2.7751900000000003, 2.98518, 4.58477, 3.61503 }
    }
    , 
    { 0.79044, 0.60449, DBL_MAX, 0.06853000000000001, 2.7145, 0.0, DBL_MAX,
    { 2.87845, 5.16745, 1.8728, 2.45614, 4.38927, 3.49005, 3.84779, 3.84247, 2.7228, 1.98203, 4.279, 1.9684, 3.98743, 3.01012, 3.21836, 2.86615, 3.13478, 3.50397, 5.65808, 4.26298 },
    { 2.6861800000000002, 4.42225, 2.7751900000000003, 2.73123, 3.46354, 2.40513, 3.72494, 3.29354, 2.67741, 2.69355, 4.2469, 2.90347, 2.73739, 3.18146, 2.89801, 2.37887, 2.7751900000000003, 2.98518, 4.58477, 3.61503 }
    }
}};
