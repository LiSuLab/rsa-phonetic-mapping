function [M, PHONES, FEATURES] = phonetic_feature_matrix()
    M = [ ...
        ...%    AA AE AH AO AW AY B  CH D  DH EA EH ER EY F  G  HH IA IH IY JH K  L  M  N  NG OH OW OY P  R  S  SH T  TH UA UH UW V  W  Y  Z  ZH  
        ...%  1. DORSAL  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
                0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  1  0  0  0  1  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  1 ; ...
        ...%  2. CORONAL
                0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  1  0  1  0  0  0  0  0  0  0  1  0 ; ...
        ...%  3. LABIAL
                0  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  1  0  0  0  0  0  1  0  0  0  0  0  0  0  0  1  0  0  0  0 ; ...
        ...%  4. HIGH
                0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  1  1  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  1  0  0  0  0  0 ; ...
        ...%  5. FRONT
                0  1  0  0  0  0  0  0  0  0  1  1  0  0  0  0  0  1  1  1  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ; ...
        ...%  6. LOW
                1  1  1  1  0  0  0  0  0  0  1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  1  0  0  0  0  0  0  1  0  0  0  0  0  0  0 ; ...
        ...%  7. BACK
                1  0  1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  1  0  0  0  0  0  0  0  0  1  0  0  0  0  0 ; ...
        ...%  8. PLOSIVE
                0  0  0  0  0  0  1  0  1  0  0  0  0  0  0  1  0  0  0  0  0  1  0  0  0  0  0  0  0  1  0  0  0  1  0  0  0  0  0  0  0  0  0 ; ...
        ...%  9. FRICATIVE
                0  0  0  0  0  0  0  1  0  1  0  0  0  0  1  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  1  0  1  0  0  0  1  0  0  1  1 ; ...
        ...% 10. SYLLABIC
                1  1  1  1  1  1  0  0  0  0  1  1  1  1  0  0  0  1  1  1  0  0  0  0  0  0  1  1  1  0  0  0  0  0  0  1  1  1  0  0  0  0  0 ; ...
        ...% 11. NASAL
                0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ; ...
        ...% 12. VOICED
                1  1  1  1  1  1  1  0  1  1  1  1  1  1  0  1  0  1  1  1  1  0  1  1  1  1  1  1  1  0  1  0  0  0  0  1  1  1  1  1  1  1  1 ; ...
        ...% 13. OBSTRUENT
                0  0  0  0  0  0  1  1  1  1  0  0  0  0  1  1  1  0  0  0  1  1  1  1  1  1  0  0  0  1  1  1  1  1  1  0  0  0  1  1  0  1  1 ; ...
        ...% 14. SONORANT
                1  1  1  1  1  1  0  0  0  0  1  1  1  1  0  0  0  1  1  1  0  0  1  0  0  0  1  1  1  0  1  0  0  0  0  1  1  1  0  1  1  0  0 ];
    
    PHONES{1}  = 'AA';
    PHONES{2}  = 'AE';
    PHONES{3}  = 'AH';
    PHONES{4}  = 'AO';
    PHONES{5}  = 'AW';
    PHONES{6}  = 'AY';
    PHONES{7}  = 'B';
    PHONES{8}  = 'CH';
    PHONES{9}  = 'D';
    PHONES{10} = 'DH';
    PHONES{11} = 'EA';
    PHONES{12} = 'EH';
    PHONES{13} = 'ER';
    PHONES{14} = 'EY';
    PHONES{15} = 'F';
    PHONES{16} = 'G';
    PHONES{17} = 'HH';
    PHONES{18} = 'IA';
    PHONES{19} = 'IH';
    PHONES{20} = 'IY';
    PHONES{21} = 'JH';
    PHONES{22} = 'K';
    PHONES{23} = 'L';
    PHONES{24} = 'M';
    PHONES{25} = 'N';
    PHONES{26} = 'NG';
    PHONES{27} = 'OH';
    PHONES{28} = 'OW';
    PHONES{29} = 'OY';
    PHONES{30} = 'P';
    PHONES{31} = 'R';
    PHONES{32} = 'S';
    PHONES{33} = 'SH';
    PHONES{34} = 'T';
    PHONES{35} = 'TH';
    PHONES{36} = 'UA';
    PHONES{37} = 'UH';
    PHONES{38} = 'UW';
    PHONES{39} = 'V';
    PHONES{40} = 'W';
    PHONES{41} = 'Y';
    PHONES{42} = 'Z';
    PHONES{43} = 'ZH';

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
