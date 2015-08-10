% The values are the number of stars in the significance threshold.
%
% CW 2015-07
function thresholds = custom_feature_thresholds_dnn()

    thresholds = struct();
    
    thresholds.DORSAL.L = 1;
    thresholds.DORSAL.R = 1;

    thresholds.CORONAL.L = 0;
    thresholds.CORONAL.R = 2;

    thresholds.LABIAL.L = 0;
    thresholds.LABIAL.R = 2;

    thresholds.HIGH.L = 0;
    thresholds.HIGH.R = 0;

    thresholds.FRONT.L = 0;
    thresholds.FRONT.R = 1;

    thresholds.LOW.L = 1;
    thresholds.LOW.R = 0;

    thresholds.BACK.L = 0;
    thresholds.BACK.R = 0;

    thresholds.PLOSIVE.L = 0;
    thresholds.PLOSIVE.R = 3;

    thresholds.FRICATIVE.L = 0;
    thresholds.FRICATIVE.R = 0;

    thresholds.SYLLABIC.L = 4;
    thresholds.SYLLABIC.R = 1;

    thresholds.NASAL.L = 2;
    thresholds.NASAL.R = 1;

    thresholds.VOICED.L = 3;
    thresholds.VOICED.R = 3;

    thresholds.OBSTRUENT.L = 1;
    thresholds.OBSTRUENT.R = 1;

    thresholds.SONORANT.L = 4;
    thresholds.SONORANT.R = 0;

end%function
