fn classify(n: i32) -> &'static str {
    match n {
        0 => "zero",
        _ => "other",
    }
}
