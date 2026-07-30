// ============================================================
//  DRYING CHAMBER / Сушильная камера
//  Included from scad/main.scad only (requires config.scad
//  and fittings.scad to be included beforehand).
// ============================================================

// ---------- Chamber body / Корпус камеры ----------
// Открыта сверху (закрывается крышкой drying_lid). Внутри —
// пары реек-направляющих для n_trays выдвижных лотков.
// Сбоку, на высоте inlet_port_z, врезан штуцер холодного воздуха
// от диафрагмы вихревой трубы (короткий силиконовый шланг).
module drying_chamber_body() {
    inner_r = max(0.5, box_corner_r - box_wall);
    union() {
        difference() {
            rounded_rect(chamber_w, chamber_d, chamber_h, box_corner_r);
            // внутренняя полость (дно остаётся, верх открыт)
            translate([box_wall, box_wall, box_wall])
                rounded_rect(chamber_w - 2 * box_wall, chamber_d - 2 * box_wall,
                             chamber_h, inner_r);
            // отверстие входного порта в стенке
            translate([-2, chamber_d / 2, inlet_port_z])
                rotate([0, 90, 0])
                    cylinder(h = box_wall + 4, d = hose_id_cold, $fn = 32);
        }
        // рейки-направляющие для лотков (пара на каждый ярус)
        for (t = [0 : n_trays - 1]) {
            z = box_wall + inlet_port_z + 18 + t * tray_gap;
            translate([box_wall, box_corner_r, z])
                cube([rail_w, chamber_d - 2 * box_corner_r, rail_h]);
            translate([chamber_w - box_wall - rail_w, box_corner_r, z])
                cube([rail_w, chamber_d - 2 * box_corner_r, rail_h]);
        }
        // наружный штуцер-нипель под шланг холодного воздуха
        translate([0, chamber_d / 2, inlet_port_z])
            rotate([0, -90, 0])
                difference() {
                    hose_barb(hose_id_cold);
                    hose_barb_bore(hose_id_cold, box_wall + barb_len + 4);
                }
    }
}

// ---------- Lid / Крышка ----------
// Плотная посадка на внутренний периметр корпуса (трение),
// перфорирована для выхода влажного воздуха наружу.
module drying_lid() {
    inner_r  = max(0.5, box_corner_r - box_wall);
    lip_w    = 1.2;
    lip_r    = max(0.3, inner_r - tray_clear);
    field_w  = chamber_w - 2 * box_corner_r;
    field_d  = chamber_d - 2 * box_corner_r;
    union() {
        // верхняя плита с перфорацией под выход пара/влажного воздуха
        difference() {
            rounded_rect(chamber_w, chamber_d, box_wall, box_corner_r);
            translate([box_corner_r, box_corner_r, -1])
                perforation_field(field_w, field_d, vent_hole_d, vent_hole_pitch, box_wall + 2);
        }
        // посадочный борт (входит внутрь корпуса с зазором tray_clear)
        translate([box_wall + tray_clear, box_wall + tray_clear, -lid_lip_h])
            difference() {
                rounded_rect(chamber_w - 2 * box_wall - 2 * tray_clear,
                             chamber_d - 2 * box_wall - 2 * tray_clear,
                             lid_lip_h, lip_r);
                translate([lip_w, lip_w, -1])
                    rounded_rect(chamber_w - 2 * box_wall - 2 * tray_clear - 2 * lip_w,
                                 chamber_d - 2 * box_wall - 2 * tray_clear - 2 * lip_w,
                                 lid_lip_h + 2, max(0.1, lip_r - lip_w));
            }
    }
}

// ---------- Perforated tray / Перфорированный лоток ----------
// Выдвигается по рейкам корпуса. Дно — перфорация под ягоды/
// микрозелень (пропускает поток холодного сухого воздуха вверх,
// удерживает продукт); невысокий бортик + пазы-ручки по торцам.
module tray() {
    inner_r  = max(0.5, box_corner_r - box_wall - rail_w);
    tray_w   = chamber_w - 2 * box_wall - 2 * tray_clear - 2 * rail_w;
    tray_d   = chamber_d - 2 * box_wall - 2 * tray_clear;
    field_w  = tray_w - 2 * tray_border;
    field_d  = tray_d - 2 * tray_border;
    difference() {
        union() {
            // дно
            rounded_rect(tray_w, tray_d, tray_wall, inner_r);
            // бортик (полый короб по периметру)
            difference() {
                rounded_rect(tray_w, tray_d, tray_border, inner_r);
                translate([tray_wall, tray_wall, tray_wall])
                    rounded_rect(tray_w - 2 * tray_wall, tray_d - 2 * tray_wall,
                                 tray_border, max(0.1, inner_r - tray_wall));
            }
        }
        // перфорация дна
        translate([tray_border, tray_border, -1])
            perforation_field(field_w, field_d, tray_hole_d, tray_hole_pitch, tray_wall + 2);
        // пазы-ручки по торцам для удобного извлечения лотка
        translate([tray_w / 2 - 9, -1, tray_border - 4])
            cube([18, tray_wall + 2, 5]);
        translate([tray_w / 2 - 9, tray_d - tray_wall - 1, tray_border - 4])
            cube([18, tray_wall + 2, 5]);
    }
}
