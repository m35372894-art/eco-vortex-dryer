// ============================================================
//  VORTEX TUBE / Вихревая труба Ранка-Хилша
//  Included from scad/main.scad only (requires config.scad
//  and fittings.scad to be included beforehand).
// ============================================================

// ---------- Tangential nozzle cutter / Тангенциальное сопло ----------
// Ось сопла НЕ проходит через центр камеры, а смещена так, что
// касается внутренней расточки — именно это закручивает поток
// (в отличие от радиального отверстия, которое просто бьёт в центр).
module tangential_nozzle(index) {
    a = index * (360 / n_nozzles);
    tangential_offset = d_chamber / 2 - d_nozzle / 2;
    cut_len = chamber_od * 1.6;
    rotate([0, 0, a])
        translate([0, tangential_offset, 0])
            rotate([0, 90, 0])
                translate([0, 0, -cut_len / 2])
                    cylinder(h = cut_len, d = d_nozzle, $fn = 32);
}

// ---------- Vortex generator body / Корпус генератора закрутки ----------
// z = 0            : фланец к холодной диафрагме (термовставки)
// z = chamber_len  : фланец к горячей трубе (сквозные отверстия)
module vortex_generator() {
    difference() {
        union() {
            cylinder(h = chamber_len, d = chamber_od);
            cylinder(h = flange_t, d = flange_od);
            translate([0, 0, chamber_len - flange_t])
                cylinder(h = flange_t, d = flange_od);
        }
        // сквозная центральная полость
        translate([0, 0, -1])
            cylinder(h = chamber_len + 2, d = d_chamber);
        // тангенциальные сопла
        for (i = [0 : n_nozzles - 1])
            translate([0, 0, chamber_len * 0.5])
                tangential_nozzle(i);
        // холодный фланец: термовставки M3
        translate([0, 0, -0.5])
            bolt_circle(flange_od - 10, 4)
                insert_hole(m3_insert_depth + 0.5, m3_insert_d);
        // горячий фланец: сквозные отверстия под винт
        translate([0, 0, chamber_len - flange_t - 0.5])
            bolt_circle(flange_od - 10, 4)
                clearance_hole(flange_t * 2 + 1, m3_clear_d);
    }
    // внешние патрубки сопел под шланг подачи воздуха от компрессора
    for (i = [0 : n_nozzles - 1]) {
        a = i * (360 / n_nozzles);
        rotate([0, 0, a])
            translate([d_chamber / 2 + wall, 0, chamber_len * 0.5])
                rotate([0, 90, 0])
                    difference() {
                        hose_barb(hose_id_supply);
                        hose_barb_bore(hose_id_supply);
                    }
    }
}

// ---------- Hot tube / Горячая труба ----------
// z = 0          : фланец к генератору (термовставки)
// z = l_hot_tube : фланец к клапанному узлу (термовставки)
module hot_tube() {
    difference() {
        union() {
            cylinder(h = l_hot_tube, d = chamber_od);
            cylinder(h = flange_t, d = flange_od);
            translate([0, 0, l_hot_tube - flange_t])
                cylinder(h = flange_t, d = flange_od);
        }
        translate([0, 0, -1])
            cylinder(h = l_hot_tube + 2, d = d_chamber);
        translate([0, 0, -0.5])
            bolt_circle(flange_od - 10, 4)
                insert_hole(m3_insert_depth + 0.5, m3_insert_d);
        translate([0, 0, l_hot_tube - flange_t - 0.5])
            bolt_circle(flange_od - 10, 4)
                insert_hole(m3_insert_depth + 0.5, m3_insert_d);
    }
}

// ---------- Cold orifice diaphragm / Холодная диафрагма ----------
// Стоит на z=0 генератора. Центральное отверстие d_cold_orifice
// пропускает возвратный (холодный) поток; O-ring обеспечивает
// герметичность; интегрированный штуцер уводит холодный воздух
// коротким силиконовым шлангом в сушильную камеру.
module cold_orifice_plate() {
    difference() {
        union() {
            cylinder(h = diaphragm_t, d = flange_od);
            translate([0, 0, -barb_len])
                difference() {
                    hose_barb(hose_id_cold);
                    hose_barb_bore(hose_id_cold);
                }
        }
        translate([0, 0, -barb_len - 1])
            cylinder(h = diaphragm_t + barb_len + 2, d = d_cold_orifice);
        translate([0, 0, diaphragm_t - oring_groove_d])
            oring_groove(chamber_od - wall);
        translate([0, 0, -0.5])
            bolt_circle(flange_od - 10, 4)
                clearance_hole(diaphragm_t + 1, m3_clear_d);
    }
}

// ---------- Control-valve housing / Корпус регулировочного клапана ----------
// Крепится на дальний (горячий) фланец hot_tube. Внутри скользит
// valve_rod с конусом, который прикрывает выход горячего воздуха.
module valve_housing() {
    housing_len = valve_cone_len + valve_travel + 10;
    difference() {
        union() {
            cylinder(h = flange_t, d = flange_od);
            translate([0, 0, flange_t - 0.01])
                cylinder(h = housing_len, d = chamber_od);
            translate([0, 0, flange_t + housing_len - 0.01])
                cylinder(h = wall * 1.5, d = chamber_od);
        }
        // внутренняя полость (строго по диаметру трубы — конус клапана дросселирует выход)
        translate([0, 0, -1])
            cylinder(h = flange_t + housing_len + wall * 1.5 + 2, d = d_chamber);
        // направляющее отверстие под шток в торцевой стенке
        translate([0, 0, flange_t + housing_len - 0.01])
            cylinder(h = wall * 1.5 + 2, d = valve_rod_d + 0.6);
        // фланец: сквозные отверстия под винт (стягиваются в термовставки hot_tube)
        translate([0, 0, -0.5])
            bolt_circle(flange_od - 10, 4)
                clearance_hole(flange_t + 1, m3_clear_d);
        // вентиляционные прорези — выход горячего воздуха наружу
        for (i = [0 : housing_vent_n - 1])
            rotate([0, 0, i * (360 / housing_vent_n)])
                translate([d_chamber / 2 - 2, -housing_vent_w / 2, flange_t + valve_cone_len])
                    cube([wall * 3 + 2, housing_vent_w, housing_len * 0.6]);
        // прорезь для фиксирующего штифта штока (видна снаружи торца)
        translate([0, 0, flange_t + housing_len - 0.01])
            rotate([0, 0, 90])
                cube([pin_hole_d + 0.6, valve_travel + 6, wall * 2], center = true);
    }
}

// ---------- Knurled handle / Рифлёная ручка ----------
module knurled_handle(d, h, teeth = 16) {
    union() {
        cylinder(h = h, d = d * 0.82, $fn = 48);
        for (i = [0 : teeth - 1])
            rotate([0, 0, i * (360 / teeth)])
                translate([d * 0.35, 0, 0])
                    cylinder(h = h, d = d * 0.22, $fn = 12);
    }
}

// ---------- Valve rod / Шток регулировочного клапана ----------
// Конус (d1 - широкий, у выхода трубы) -> шток -> рифлёная ручка.
// Положение фиксируется штифтом (скрепка/печатный штифт 2 мм) через
// ближайшее из отверстий pin_hole, упирающееся в торец корпуса клапана.
module valve_rod() {
    handle_h = 16;
    rod_len = valve_cone_len + valve_travel + handle_h + 6;
    n_pins = floor(valve_travel / pin_hole_pitch);
    difference() {
        union() {
            cylinder(h = valve_cone_len, d1 = d_chamber * 0.8, d2 = valve_rod_d * 1.5, $fn = 64);
            translate([0, 0, valve_cone_len])
                cylinder(h = rod_len - valve_cone_len, d = valve_rod_d, $fn = 32);
            translate([0, 0, rod_len - handle_h])
                knurled_handle(d = valve_rod_d + 6, h = handle_h);
        }
        // ряд поперечных отверстий фиксации хода
        for (i = [0 : n_pins])
            translate([0, 0, valve_cone_len + valve_travel * 0.3 + i * pin_hole_pitch])
                rotate([90, 0, 0])
                    cylinder(h = valve_rod_d * 2, d = pin_hole_d, center = true, $fn = 16);
    }
}
