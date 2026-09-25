fn main() {
    // Deliberate type error: change "hello" to 42, save, then run :CargoCheck again.
    let answer: i32 = "hello";
    println!("{answer}");
}
