fun classify(x: Int): String {
    if (x > 0) {
        return "positive"
    }
    return when (x) {
        0 -> "zero"
        else -> "other"
    }
}
