% The values are the number of stars in the significance threshold.
%
% CW 2015-07
function thresholds = custom_feature_thresholds()

    thresholds = struct();
    
    thresholds.DORSAL.L = 0;
    thresholds.DORSAL.R = 1;

    thresholds.CORONAL.L = 0;
    thresholds.CORONAL.R = 0;

    thresholds.LABIAL.L = 2;
    thresholds.LABIAL.R = 0;

    thresholds.HIGH.L = 1;
    thresholds.HIGH.R = 1;

    thresholds.FRONT.L = 2;
    thresholds.FRONT.R = 1;

    thresholds.LOW.L = 1;
    thresholds.LOW.R = 1;

    thresholds.BACK.L = 1;
    thresholds.BACK.R = 1;

    thresholds.PLOSIVE.L = 0;
    thresholds.PLOSIVE.R = 1;

    thresholds.FRICATIVE.L = 0;
    thresholds.FRICATIVE.R = 0;
    
    thresholds.SYLLABIC.L = 1;
    thresholds.SYLLABIC.R = 1;

    thresholds.NASAL.L = 1;
    thresholds.NASAL.R = 1;

    thresholds.VOICED.L = 0;
    thresholds.VOICED.R = 1;

    thresholds.OBSTRUENT.L = 0;
    thresholds.OBSTRUENT.R = 1;

    thresholds.SONORANT.L = 0;
    thresholds.SONORANT.R = 1;

end%function
