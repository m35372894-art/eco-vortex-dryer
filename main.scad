// ============================================================
//  ECO-DRYER (Ranque-Hilsch effect) — MAIN
//  Эко-Сушилка для микрозелени и ягод на эффекте Ранка-Хилша
//  ------------------------------------------------------------
//  THIS is the file to open in OpenSCAD. It composes the whole
//  project from scad/*.scad in the correct order.
//
//  HOW TO EXPORT STL FOR PRINTING / Печать по частям:
//    1) Set the `part` variable below to one of the values listed.
//    2) Render (F6) and Export as STL (F7), or use the CLI:
//         openscad -o out/<name>.stl -D part=\"hot_tube\" scad/main.scad
//    3) Repeat for every part. Print `tray` three times (n_trays).
//
//  See also: .github/workflows/render.yml — CI renders every part
//  to STL automatically on every push.
// ============================================================

include <config.scad>
include <fittings.scad>
include <vortex_tube.scad>
include <drying_chamber.scad>

// ---------- Part selector / Выбор детали для экспорта ----------
// "all"               -> обзорная сборка (НЕ для печати, только просмотр)
// "generator"         -> корпус вихревого генератора
// "cold_orifice_plate"-> холодная диафрагма со штуцером
// "hot_tube"          -> горячая труба
// "valve_housing"     -> корпус регулировочного клапана
// "valve_rod"         -> шток клапана с ручкой
// "chamber_body"      -> корпус сушильной камеры
// "lid"               -> крышка сушильной камеры
// "tray"              -> лоток (печатать n_trays раз)
part = "all";

// Показывать сборку в "разнесённом" виде (для иллюстраций/README)
explode = false;
gap = explode ? explode_gap : 0;

// ============================================================
//  FULL ASSEMBLY / Полная сборка (для просмотра, не для печати)
// ============================================================
module vortex_tube_assembly() {
    // Труба лежит горизонтально вдоль оси X: Z локальных деталей -> X сборки.
    rotate([0, 90, 0]) {
        // холодная диафрагма (торчит штуцером в -Z локальных координат,
        // т.е. после поворота — в -X мировых)
        color("SteelBlue") cold_orifice_plate();

        translate([0, 0, gap])
            color("LightGray") vortex_generator();

        translate([0, 0, chamber_len + 2 * gap])
            color("LightGray") hot_tube();

        translate([0, 0, chamber_len + l_hot_tube + 3 * gap])
            color("Orange") valve_housing();

        translate([0, 0, chamber_len + l_hot_tube + flange_t + 4 * gap])
            color("DarkOrange") valve_rod();
    }
}

module drying_chamber_assembly() {
    color("Wheat", 0.95) drying_chamber_body();

    translate([0, 0, chamber_h + gap])
        color("Wheat", 0.7) drying_lid();

    for (t = [0 : n_trays - 1]) {
        z = box_wall + inlet_port_z + 18 + t * tray_gap + rail_h + tray_clear;
        translate([box_wall + tray_clear + rail_w, box_wall + tray_clear, z + t * gap * 0.3])
            color("YellowGreen") tray();
    }
}

module full_assembly() {
    drying_chamber_assembly();
    // вихревая труба размещена сбоку от камеры, соединяется коротким
    // силиконовым шлангом между штуцером диафрагмы и штуцером камеры
    // (шланг — гибкая деталь, в STL не входит, докупается отдельно)
    translate([-l_hot_tube - chamber_len - flange_t * 3 - 60 - gap, chamber_d / 2, inlet_port_z])
        vortex_tube_assembly();
}

// ============================================================
//  RENDER SWITCH / Переключатель вывода по значению `part`
// ============================================================
if (part == "all")                  full_assembly();
else if (part == "generator")       vortex_generator();
else if (part == "cold_orifice_plate") cold_orifice_plate();
else if (part == "hot_tube")        hot_tube();
else if (part == "valve_housing")   valve_housing();
else if (part == "valve_rod")       valve_rod();
else if (part == "chamber_body")    drying_chamber_body();
else if (part == "lid")             drying_lid();
else if (part == "tray")            tray();
else assert(false, str("Unknown part: ", part));
