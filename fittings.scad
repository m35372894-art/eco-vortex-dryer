// ============================================================
//  FITTINGS & HELPERS / Крепёж, штуцеры, служебные модули
//  Included from scad/main.scad only.
// ============================================================

// ---------- Rounded rectangle prism (hull of 4 corner posts) ----------
// Скруглённый прямоугольный параллелепипед — база для корпуса
// сушильной камеры и лотков (гигиенично, легко мыть, без острых углов).
module rounded_rect(w, d, h, r) {
    hull() {
        for (x = [r, w - r])
            for (y = [r, d - r])
                translate([x, y, 0])
                    cylinder(h = h, r = r);
    }
}

// ---------- Perforation field / Поле перфорации ----------
// Прямоугольная сетка сквозных отверстий, отцентрованная в w x d.
// cutter_h должен быть заведомо больше толщины стенки, чтобы
// гарантированно "простреливать" материал насквозь.
module perforation_field(w, d, hole_d, pitch, cutter_h) {
    nx = max(1, floor((w - hole_d) / pitch) + 1);
    ny = max(1, floor((d - hole_d) / pitch) + 1);
    ox = (w - (nx - 1) * pitch) / 2;
    oy = (d - (ny - 1) * pitch) / 2;
    for (i = [0 : nx - 1])
        for (j = [0 : ny - 1])
            translate([ox + i * pitch, oy + j * pitch, 0])
                cylinder(h = cutter_h, d = hole_d, center = true);
}

// ---------- Hose barb / Штуцер под силиконовый шланг ----------
// Направлен вдоль +Z, основание в начале координат.
// Печатается заодно с деталью (без поддержек, угол елочки печатается вверх).
module hose_barb(hose_id, len = barb_len, rings = barb_rings, wall_t = 1.6) {
    d_stem = hose_id + 2 * wall_t;
    d_bulge = hose_id + 2 * wall_t + 1.6;
    ring_h = len / rings;
    union() {
        // конический хвостовик у основания — прочный переход
        cylinder(h = 2, d1 = d_stem + 3, d2 = d_stem, $fn = 32);
        // ёлочка колец удержания шланга
        translate([0, 0, 2])
            for (i = [0 : rings - 1])
                translate([0, 0, i * ring_h])
                    cylinder(h = ring_h, d1 = d_stem, d2 = d_bulge, $fn = 32);
    }
}

// сквозной канал внутри штуцера — вычитать отдельно тем же h
module hose_barb_bore(hose_id, len = barb_len + 4) {
    cylinder(h = len, d = hose_id, $fn = 32);
}

// ---------- Heat-set insert hole / Отверстие под термовставку M3 ----------
// Печатается в теле детали; после печати латунная вставка впаивается
// паяльником. Второе, сквозное отверстие — под сам винт в ответной части.
module insert_hole(depth = m3_insert_depth, d = m3_insert_d) {
    cylinder(h = depth, d = d, $fn = 24);
}

module clearance_hole(len, d = m3_clear_d) {
    cylinder(h = len, d = d, $fn = 24);
}

// ---------- O-ring groove / Канавка под уплотнительное кольцо ----------
// Прямоугольная канавка (в сечении) на цилиндрической посадочной поверхности.
module oring_groove(d_seat, groove_w = oring_groove_w, groove_d = oring_groove_d) {
    rotate_extrude($fn = 96)
        translate([d_seat / 2 - groove_d, -groove_w / 2, 0])
            square([groove_d + 0.5, groove_w]);
}

// ---------- Bolt-circle pattern helper / Раскладка отверстий по окружности ----------
module bolt_circle(d_bc, n, start_angle = 0) {
    for (i = [0 : n - 1]) {
        a = start_angle + i * (360 / n);
        rotate([0, 0, a])
            translate([d_bc / 2, 0, 0])
                children();
    }
}
