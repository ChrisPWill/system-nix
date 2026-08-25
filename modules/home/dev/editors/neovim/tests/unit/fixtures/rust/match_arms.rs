fn classify(n: i32) -> &'static str {
    match n {
        0 => "zero",
        n if n > 0 => "positive",
        _ => "negative",
    }
}
