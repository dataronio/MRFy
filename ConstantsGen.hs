module ConstantsGen where

import Data.Vector

bgFreqs = fromList [
                        0.0787945,		-- A
                        0.0151600,		-- C
                        0.0535222,		-- D
                        0.0668298,		-- E
                        0.0397062,		-- F
                        0.0695071,		-- G
                        0.0229198,		-- H
                        0.0590092,		-- I
                        0.0594422,		-- K
                        0.0963728,		-- L
                        0.0237718,		-- M
                        0.0414386,		-- N
                        0.0482904,		-- P
                        0.0395639,		-- Q
                        0.0540978,		-- R
                        0.0683364,		-- S
                        0.0540687,		-- T
                        0.0673417,		-- V
                        0.0114135,		-- W
                        0.0304133,		-- Y
                        1				-- X
                    ]


betaBuried = fromList [
                      fromList [ 2.84366275993, 2.8903717579, 2.4159137783, 1.63413052502, 2.58399755243, 3.31418600467, 2.06369318471, 2.54299056115, 2.8903717579, 2.42645457471, 2.9103724246, 2.30258509299, 2.66258782703, 3.06805293513, 3.52636052462, 2.68970106243, 2.47293045874, 2.54241114427, 2.53016324138, 2.60268968544, 9.21034037198 ],
                      fromList [ 3.77797199731, 2.19722457734, 3.33220451018, 3.7135720667, 3.56482680544, 3.13186444788, 3.44998754583, 3.65343730746, 2.8903717579, 3.57001825124, 4.20965540873, 3.40119738166, 1.96944064647, 3.76120011569, 3.52636052462, 3.14168618618, 3.1660776393, 3.81404259707, 2.78147766966, 3.4781584228, 9.21034037198 ],
                      fromList [ 4.56642935767, 4.59511985013, 4.73651168254, 4.73651168254, 5.06890420222, 3.82501162844, 4.14313472639, 4.7884172403, 4.73651168254, 5.5510197201, 4.61512051684, 2.99573227355, 3.06805293513, 4.73651168254, 2.83321334406, 3.4781584228, 5.11198778836, 4.73033332894, 4.73651168254, 5.78074351579, 9.21034037198 ],
                      fromList [ 4.09642572843, 5.28826703069, 5.04829130657, 3.02042488614, 4.66343909411, 5.61677109767, 3.44998754583, 5.03973166858, 2.19722457734, 5.32787616879, 4.20965540873, 5.04829130657, 5.04829130657, 5.04829130657, 5.04829130657, 4.39444915467, 5.11198778836, 6.52209279817, 5.04829130657, 5.08759633523, 9.21034037198 ],
                      fromList [ 2.3046662592, 2.3978952728, 2.63905732962, 1.92181259748, 2.12446522305, 1.97918493794, 2.19722457734, 2.47478231112, 2.19722457734, 2.39401929895, 2.13021386705, 2.99573227355, 2.15176220326, 1.96944064647, 2.42774823595, 1.9521021193, 2.16754880919, 2.40305562336, 2.42480272572, 2.19722457734, 9.21034037198 ],
                      fromList [ 3.87328217711, 2.80336038091, 2.23359222151, 3.7135720667, 2.81761240361, 2.72639933977, 2.53369681396, 3.32208017151, 3.14509227561, 3.2997279215, 3.51650822817, 4.09434456222, 1.96944064647, 3.76120011569, 3.52636052462, 3.4781584228, 2.80940269536, 3.10436611456, 3.62877553004, 2.94753017174, 9.21034037198 ],
                      fromList [ 4.09642572843, 4.59511985013, 4.02535169074, 3.02042488614, 4.50928841428, 4.00733318523, 2.75684036527, 5.03973166858, 4.61872864688, 4.99140393217, 4.61512051684, 4.09434456222, 4.61872864688, 3.76120011569, 4.61872864688, 3.295836866, 4.4188406078, 5.82894561761, 4.72738781871, 4.68213122712, 9.21034037198 ],
                      fromList [ 1.73321601362, 1.95606252052, 1.8281271134, 1.76766191765, 1.94433905682, 1.95320945154, 2.19722457734, 1.58296443577, 1.79175946923, 1.72237832361, 1.67068153767, 2.14843441317, 2.37490575457, 1.96944064647, 2.83321334406, 1.86872051036, 2.47293045874, 1.73044304524, 1.83701606082, 1.84891788307, 9.21034037198 ],
                      fromList [ 6.17586727011, 5.28826703069, 5.87149161538, 3.02042488614, 5.76205138278, 5.87149161538, 5.87149161538, 5.88702952897, 5.87149161538, 5.32787616879, 5.87149161538, 5.87149161538, 5.87149161538, 3.76120011569, 3.52636052462, 5.08759633523, 5.87149161538, 6.11662769006, 5.87149161538, 5.87149161538, 9.21034037198 ],
                      fromList [ 1.66500776359, 1.92097120071, 2.63905732962, 2.10413415427, 1.91190378107, 1.97918493794, 2.19722457734, 1.77070606003, 1.28093384546, 1.71156740751, 1.78190717279, 2.01490302054, 2.37490575457, 2.15176220326, 2.83321334406, 1.99655388187, 1.89311196349, 1.83074491594, 2.01933761761, 1.79175946923, 9.21034037198 ],
                      fromList [ 3.77797199731, 4.18965474203, 3.33220451018, 2.61495977804, 3.27714473299, 3.82501162844, 3.44998754583, 3.34805565791, 3.45359567587, 3.41095355661, 2.82336104761, 4.09434456222, 3.76120011569, 2.37490575457, 3.52636052462, 5.08759633523, 3.1660776393, 3.52636052462, 3.62877553004, 3.38284824299, 9.21034037198 ],
                      fromList [ 4.38410780088, 4.59511985013, 2.92673940207, 4.66751881105, 5.35658627467, 5.61677109767, 4.14313472639, 5.03973166858, 4.66751881105, 4.85787253954, 5.3082676974, 4.66751881105, 3.76120011569, 3.06805293513, 3.52636052462, 4.39444915467, 3.32022831913, 4.91265488574, 3.11794990628, 5.78074351579, 9.21034037198 ],
                      fromList [ 5.07725498144, 3.49650756147, 3.33220451018, 5.00066325758, 4.84576065091, 3.82501162844, 5.00066325758, 5.59934745652, 5.00066325758, 5.5510197201, 5.3082676974, 4.09434456222, 5.00066325758, 3.76120011569, 5.00066325758, 4.39444915467, 5.11198778836, 6.11662769006, 3.34109345759, 5.08759633523, 9.21034037198 ],
                      fromList [ 5.48272008955, 5.28826703069, 5.00066325758, 5.00066325758, 4.66343909411, 5.61677109767, 4.14313472639, 5.19388234841, 2.8903717579, 5.32787616879, 3.92197333628, 3.40119738166, 3.76120011569, 5.00066325758, 3.52636052462, 3.98898404656, 5.11198778836, 5.01801540139, 4.03424063815, 5.78074351579, 9.21034037198 ],
                      fromList [ 6.17586727011, 5.28826703069, 3.33220451018, 5.23550284866, 5.35658627467, 5.61677109767, 5.23550284866, 6.29249463708, 2.8903717579, 6.24416690066, 5.3082676974, 4.09434456222, 5.23550284866, 3.76120011569, 5.23550284866, 5.08759633523, 3.72569342724, 5.01801540139, 4.03424063815, 4.17130560336, 9.21034037198 ],
                      fromList [ 3.77797199731, 3.34235688164, 2.4159137783, 3.02042488614, 3.31970434741, 4.00733318523, 2.35137525716, 3.76676599277, 2.8903717579, 3.84627162787, 5.3082676974, 3.40119738166, 3.06805293513, 2.66258782703, 3.52636052462, 2.44853900562, 5.11198778836, 4.12419752537, 3.11794990628, 3.83483336674, 9.21034037198 ],
                      fromList [ 3.53680994049, 3.34235688164, 4.02535169074, 3.7135720667, 3.51075958417, 3.31418600467, 3.44998754583, 4.34658448802, 3.64987558492, 3.71843825636, 3.36235754835, 2.30258509299, 3.76120011569, 3.76120011569, 2.1400661635, 5.08759633523, 3.72569342724, 3.47757036045, 4.03424063815, 3.38284824299, 9.21034037198 ],
                      fromList [ 1.50303843564, 1.88706964903, 1.54044504095, 3.02042488614, 1.64301420797, 1.50589723349, 2.75684036527, 1.50084488415, 1.79175946923, 1.55281901843, 1.61938824329, 1.79175946923, 2.66258782703, 1.56397553836, 1.32913594728, 1.99655388187, 1.37431817007, 1.36880120367, 2.0883304891, 1.62186043243, 9.21034037198 ],
                      fromList [ 3.97864269277, 3.34235688164, 4.03447555456, 4.03447555456, 4.15261347035, 4.518158809, 4.14313472639, 4.09527005974, 4.03447555456, 4.22926388012, 4.20965540873, 2.48490664979, 2.37490575457, 3.06805293513, 2.83321334406, 3.4781584228, 4.4188406078, 4.57618264911, 3.34109345759, 3.58351893846, 9.21034037198 ],
                      fromList [ 2.99781343976, 2.9856819377, 4.02535169074, 3.02042488614, 2.87167962488, 2.78355775361, 3.04452243772, 3.05381618491, 2.98111985748, 2.94833003466, 2.9103724246, 4.09434456222, 3.06805293513, 3.76120011569, 1.91692261218, 3.14168618618, 2.71409251556, 3.05635689537, 2.53016324138, 3.00815479355, 9.21034037198 ],
                      fromList [ 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198 ]
                      ]
                      
betaExposed = fromList [
                       fromList [ 2.91390225531, 2.56494935746, 3.1945831323, 3.50727192805, 2.97892515524, 3.19575340745, 3.04927304048, 2.98480320302, 3.56482680544, 2.8860890961, 3.11794990628, 3.31678003985, 3.44998754583, 3.86423234159, 3.18727048545, 3.37709983008, 3.60186807712, 2.90507790529, 3.81771232596, 2.83011256638, 9.21034037198 ],
                       fromList [ 3.76120011569, 2.27726728501, 5.49716822529, 6.14632925767, 3.6720723358, 5.1416635565, 4.65871095292, 4.73400305783, 4.66343909411, 4.3524261649, 4.72738781871, 4.56954300834, 4.14313472639, 5.65599181082, 4.13173209429, 4.22439769047, 4.41279829334, 4.51451581772, 3.81771232596, 3.98279207632, 9.21034037198 ],
                       fromList [ 3.25037449193, 4.35670882669, 3.70540875607, 3.84374416467, 3.6720723358, 3.19575340745, 2.95396286068, 3.34770869671, 2.68935806809, 3.43613543302, 3.34109345759, 3.31678003985, 4.14313472639, 3.0169344812, 2.74543773317, 2.92511470634, 3.27336401015, 3.82136863716, 3.1245651454, 3.57732696821, 9.21034037198 ],
                       fromList [ 2.91390225531, 4.35670882669, 3.1945831323, 2.96827542732, 2.57346004713, 3.19575340745, 2.86695148369, 2.86220088093, 1.8420602077, 2.74298825246, 2.24248116892, 2.37231843101, 2.53369681396, 2.6114693731, 2.03459097551, 2.97163472197, 2.52194792147, 2.80976772548, 2.56494935746, 3.06650134444, 9.21034037198 ],
                       fromList [ 3.06805293513, 2.56494935746, 3.70540875607, 3.25595749977, 2.69124308279, 2.57671419904, 2.64380793237, 3.72240214615, 3.63381967693, 3.19974665496, 2.64794627703, 3.65325227647, 3.44998754583, 3.57655026914, 4.46820433091, 2.92511470634, 3.31418600467, 3.53368656471, 3.1245651454, 3.28964489576, 9.21034037198 ],
                       fromList [ 3.60704943587, 4.35670882669, 3.55125807624, 4.20041910861, 2.89888244756, 3.34990408727, 3.15463355614, 3.48124008934, 4.88658264543, 3.19974665496, 2.78147766966, 3.18324864723, 4.14313472639, 4.04655389839, 3.51269288589, 3.53125050991, 4.00733318523, 3.90838001415, 3.41224721785, 3.28964489576, 9.21034037198 ],
                       fromList [ 3.25037449193, 3.66356164613, 3.09927295249, 3.66142260788, 2.75578160392, 2.94443897917, 3.56009866425, 3.55534806149, 3.50028828431, 3.50512830451, 3.11794990628, 3.87639582778, 3.04452243772, 3.57655026914, 3.77505715035, 3.37709983008, 3.40119738166, 3.36183630778, 3.81771232596, 3.0019628233, 9.21034037198 ],
                       fromList [ 2.41746536899, 2.97041446557, 2.72457950305, 2.88823271965, 3.06593653223, 2.50260622689, 2.78690877601, 2.02595285673, 2.6619590939, 2.35999600021, 2.32949254591, 2.96010509591, 2.75684036527, 2.71155283165, 2.67644486169, 2.64886132971, 2.90872089656, 2.56860566866, 2.56494935746, 2.83011256638, 9.21034037198 ],
                       fromList [ 2.84490938382, 2.74727091426, 1.91364928684, 1.71551245883, 2.82477447541, 3.75536919538, 2.57926941124, 2.50937950631, 2.44423561006, 2.56066669567, 2.24248116892, 2.42947684485, 3.44998754583, 2.36015494482, 2.81954570533, 2.92511470634, 2.62103882411, 2.72275634849, 2.31363492918, 2.13696538582, 9.21034037198 ],
                       fromList [ 2.2948630469, 2.56494935746, 2.78911802419, 2.74513187601, 2.51939282586, 2.19722457734, 2.71280080386, 2.33610778503, 2.68935806809, 2.27298462322, 2.93562834948, 3.47093071968, 1.94591014906, 2.76562005292, 2.94214802742, 2.72032029369, 3.02650393222, 2.21193072473, 2.56494935746, 2.73002910782, 9.21034037198 ],
                       fromList [ 3.94352167249, 4.35670882669, 4.11087386417, 3.66142260788, 3.38439026335, 3.19575340745, 3.74242022104, 3.72240214615, 3.78797035676, 4.3524261649, 3.34109345759, 4.16407790024, 4.14313472639, 4.2696974497, 3.88041766601, 4.22439769047, 4.54632968597, 4.22683374527, 4.51085950652, 5.08140436498, 9.21034037198 ],
                       fromList [ 3.60704943587, 3.66356164613, 3.55125807624, 3.25595749977, 3.85439389259, 3.06222201482, 3.96556377236, 3.81771232596, 3.43966366249, 4.3524261649, 3.62877553004, 3.47093071968, 3.44998754583, 3.09104245336, 3.0819099698, 3.45120780224, 3.27336401015, 4.00369019395, 3.1245651454, 3.20960218808, 9.21034037198 ],
                       fromList [ 4.85981240436, 4.35670882669, 5.49716822529, 4.53689134523, 4.77068462447, 5.1416635565, 4.25324584481, 4.73400305783, 5.57972982599, 3.94696105679, 4.72738781871, 4.56954300834, 4.59528017078, 4.96284463026, 4.46820433091, 5.32300997914, 4.88280192259, 4.36036513789, 3.81771232596, 3.69511000386, 9.21034037198 ],
                       fromList [ 3.76120011569, 4.35670882669, 2.85811089568, 3.10180681995, 3.38439026335, 3.53222564407, 3.2724165918, 3.17585843978, 2.97704014054, 3.25381387623, 3.34109345759, 2.69774083144, 3.44998754583, 2.47793798047, 3.36959204225, 3.24356843746, 2.82867818889, 3.08739946208, 2.71910003729, 3.06650134444, 9.21034037198 ],
                       fromList [ 2.66258782703, 2.41079867763, 2.16496371512, 2.10327798983, 3.85439389259, 2.57671419904, 3.04927304048, 2.71910003729, 3.01478046852, 3.0086914182, 2.53016324138, 2.26695791535, 2.53369681396, 2.94794160972, 3.59273559356, 2.68395264952, 2.46688814429, 2.49961279718, 2.20827441352, 2.83011256638, 9.21034037198 ],
                       fromList [ 2.91390225531, 2.56494935746, 2.40612577193, 3.10180681995, 2.37278935167, 2.65675690671, 2.71280080386, 2.75300158896, 3.18183455319, 2.84834876812, 2.93562834948, 2.69774083144, 3.44998754583, 2.88340308858, 2.74543773317, 2.43263822124, 2.27273212984, 3.08739946208, 2.90142159408, 2.68350909219, 9.21034037198 ],
                       fromList [ 2.66258782703, 2.27726728501, 2.27829240043, 2.17603734412, 2.28577797468, 2.65675690671, 2.26081568012, 2.53677848049, 2.40167599564, 2.67844973133, 2.78147766966, 2.04381436404, 2.53369681396, 1.99243016469, 2.05229055261, 1.79664945452, 1.84784893588, 2.1791409019, 3.81771232596, 3.13549421593, 9.21034037198 ],
                       fromList [ 2.15176220326, 2.56494935746, 3.01226157551, 2.6498216962, 2.69124308279, 2.7437682837, 2.40741915431, 2.38262780067, 2.68935806809, 2.0498410719, 2.64794627703, 2.96010509591, 2.19722457734, 2.43711598595, 2.27097975358, 2.79728133483, 2.36510544998, 2.1791409019, 2.31363492918, 2.37335416388, 9.21034037198 ],
                       fromList [ 4.85981240436, 3.66356164613, 4.11087386417, 4.20041910861, 4.07753744391, 4.04305126783, 4.65871095292, 4.1743872699, 4.07565242921, 4.19827548507, 4.72738781871, 3.87639582778, 3.44998754583, 3.86423234159, 3.77505715035, 4.40671924726, 5.79909265446, 4.10905070961, 3.81771232596, 4.38825718442, 9.21034037198 ],
                       fromList [ 2.60852060576, 2.56494935746, 3.29994364796, 3.43827905657, 2.97892515524, 2.65675690671, 2.57926941124, 3.17585843978, 2.63529084682, 3.0996631964, 4.03424063815, 2.69774083144, 2.06369318471, 2.94794160972, 3.13320326418, 2.92511470634, 3.85318250541, 2.90507790529, 3.1245651454, 2.44234703537, 9.21034037198 ],
                       fromList [ 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198, 9.21034037198 ]
                       ]
