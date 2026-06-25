function average(array) {
    let total = 0;
    for (const item of array) {
        total += item;
    }
    return total / array.length;
}

average([1, 2, 3, 4, 5]);