#![allow(unused_unsafe)]
#![allow(incomplete_features)]
#![allow(internal_features)]

#![feature(core_intrinsics)]
#![feature(generic_const_exprs)]

fn main() {
    unsafe {
        let x = 42;
        let y = std::intrinsics::type_name::<i32>(); // Intrinsics are unstable
        println!("Variable x: {}, Type: {}", x, y);
    }

    // This function uses an unstable feature in generics
    let _ = GenericStruct::<5>::new();
}

struct GenericStruct<const N: usize>
where
    [(); N - 1]:; // Uses `generic_const_exprs`, which is unstable
impl<const N: usize> GenericStruct<N>
where
    [(); N - 1]:,
{
    fn new() -> Self {
        println!("Creating GenericStruct with N = {}", N);
        Self
    }
}
