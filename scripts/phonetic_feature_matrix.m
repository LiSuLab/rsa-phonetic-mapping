function [M, PHONES, FEATURES] = phonetic_feature_matrix()
    M = [ ...
        ...%    1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40
        ...%    AA AE AH AO AW AY B  CH D  EA EH ER EY F  G  HH IA IH IY JH K  L  M  N  NG OH OW OY P  R  S  SH T  TH UH UW V  W  Y  Z  
        ...%  1. DORSAL  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
                0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  1  0  0  0  1  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0 ; ...
        ...%  2. CORONAL
                0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  1  0  1  0  0  0  0  0  0  1 ; ...
        ...%  3. LABIAL
                0  0  0  0  0  0  1  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  1  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  0  0 ; ...
        ...%  4. HIGH
                0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  1  1  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  0  0  0 ; ...
        ...%  5. FRONT
                0  1  0  0  0  0  0  0  0  1  1  0  0  0  0  0  1  1  1  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0 ; ...
        ...%  6. LOW
                1  1  1  1  0  0  0  0  0  1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0 ; ...
        ...%  7. BACK
                1  0  1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  1  0  0  0  0  0  0  0  1  0  0  0  0 ; ...
        ...%  8. PLOSIVE
                0  0  0  0  0  0  1  0  1  0  0  0  0  0  1  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  0  0  1  0  0  0  0  0  0  0 ; ...
        ...%  9. FRICATIVE
                0  0  0  0  0  0  0  1  0  0  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  1  0  1  0  0  1  0  0  1 ; ...
        ...% 10. SYLLABIC
                1  1  1  1  1  1  0  0  0  1  1  1  1  0  0  0  1  1  1  0  0  0  0  0  0  1  1  1  0  0  0  0  0  0  1  1  0  0  0  0 ; ...
        ...% 11. NASAL
                0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ; ...
        ...% 12. VOICED
                1  1  1  1  1  1  1  0  1  1  1  1  1  0  1  0  1  1  1  1  0  1  1  1  1  1  1  1  0  1  0  0  0  0  1  1  1  1  1  1 ; ...
        ...% 13. OBSTRUENT
                0  0  0  0  0  0  1  1  1  0  0  0  0  1  1  1  0  0  0  1  1  1  1  1  1  0  0  0  1  1  1  1  1  1  0  0  1  1  0  1 ; ...
        ...% 14. SONORANT
                1  1  1  1  1  1  0  0  0  1  1  1  1  0  0  0  1  1  1  0  0  1  0  0  0  1  1  1  0  1  0  0  0  0  1  1  0  1  1  0 ];
    
    PHONES{1}  = 'AA';
    PHONES{2}  = 'AE';
    PHONES{3}  = 'AH';
    PHONES{4}  = 'AO';
    PHONES{5}  = 'AW';
    PHONES{6}  = 'AY';
    PHONES{7}  = 'B';
    PHONES{8}  = 'CH';
    PHONES{9}  = 'D';
    PHONES{10} = 'EA';
    PHONES{11} = 'EH';
    PHONES{12} = 'ER';
    PHONES{13} = 'EY';
    PHONES{14} = 'F';
    PHONES{15} = 'G';
    PHONES{16} = 'HH';
    PHONES{17} = 'IA';
    PHONES{18} = 'IH';
    PHONES{19} = 'IY';
    PHONES{20} = 'JH';
    PHONES{21} = 'K';
    PHONES{22} = 'L';
    PHONES{23} = 'M';
    PHONES{24} = 'N';
    PHONES{25} = 'NG';
    PHONES{26} = 'OH';
    PHONES{27} = 'OW';
    PHONES{28} = 'OY';
    PHONES{29} = 'P';
    PHONES{30} = 'R';
    PHONES{31} = 'S';
    PHONES{32} = 'SH';
    PHONES{33} = 'T';
    PHONES{34} = 'TH';
    PHONES{35} = 'UH';
    PHONES{36} = 'UW';
    PHONES{37} = 'V';
    PHONES{38} = 'W';
    PHONES{39} = 'Y';
    PHONES{40} = 'Z';

    FEATURES{1}  = 'DORSAL';
    FEATURES{2}  = 'CORONAL';
    FEATURES{3}  = 'LABIAL';
    FEATURES{4}  = 'HIGH';
    FEATURES{5}  = 'FRONT';
    FEATURES{6}  = 'LOW';
    FEATURES{7}  = 'BACK';
    FEATURES{8}  = 'PLOSIVE';
    FEATURES{9}  = 'FRICATIVE';
    FEATURES{10} = 'SYLLABIC';
    FEATURES{11} = 'NASAL';
    FEATURES{12} = 'VOICED';
    FEATURES{13} = 'OBSTRUENT';
    FEATURES{14} = 'SONORANT';
end
