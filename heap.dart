/// Provide [Priority] as a constructor parameter to specify
/// the priority type when creating a heap.
enum Priority { max, min }

/// Since elements of a heap need to be sortable, the element type
/// extends [Comparable].
///
/// The reason for using `Comparable<dynamic>` here rather than
/// `Comparable<E>` is because this makes [int] collections easier
/// to create since int doesn't directly implement [Comparable]
/// but it's superclass num does. That makes it so that users of
/// class would have to use [num] when they really want [int]
class Heap<E extends Comparable<dynamic>> {
  /// Traversing through a tree is a O(log n) operation but access a member
  /// in a random-access data structure like [List] takes O(1) or constant time
  late final List<E> elements;
  final Priority priority;

  /// The default is a max-heap
  ///
  /// You can specify a list of elements to initialize heap with.
  Heap({List<E>? elements, this.priority = Priority.max}) {
    this.elements = (elements == null) ? [] : elements;
    _buildHeap();
  }

  ///If a non-empty list is provided, you see that as the
  ///initial elements for the heap. You loop through the list
  ///backwards, starting from the first non-leaf node, and shift
  /// all parent nodes down.
  ///You loop through only half of the elements because there's
  ///no point in shifting leaf nodes down
  void _buildHeap() {
    if (isEmpty) return;
    final start = elements.length ~/ 2 - 1;
    for (var i = start; i >= 0; i--) {
      // The bottom of the heap, on the other hand, holds half
      // of the nodes already, and it doesn't take so much work
      // to shift the relatively fewer number of nodes above
      // them down.
      _shiftDown(i);

      /// _shiftDown O(n log n)
      /// _shiftUp O(n)
    }
  }

  void merge(List<E> list) {
    elements.addAll(list);
    _buildHeap();
  }

  Heap.anotherConstructor({List<E>? elements, this.priority = Priority.max})
      : elements = elements ?? [];

  bool get isEmpty => elements.isEmpty;

  int get length => elements.length;

  /// Calling peek will give you the maximum value in the
  /// collection for a max-heap, or minimum value in the
  /// collection to a min-heap.
  /// O(1)
  E? get peek => (isEmpty) ? null : elements.first;

  int _leftChildIndex(int parentIndex) {
    return 2 * parentIndex + 1;
  }

  int _rightChildIndex(int parentIndex) {
    return 2 * parentIndex + 2;
  }

  int _parentIndex(int childIndex) {
    // print(1 ~/ 2);
    // return childIndex ~/ 2 - 1 ~/ 2;
    return (childIndex - 1) ~/ 2;
  }

  /// Compares two inputs and return a value to indicate the one
  /// with the greater priority.
  ///
  /// Compares any two values. In a max-heap, the higher value
  /// has a greater priority and in a min-heap the lower value
  /// has a greater priority.
  bool _firstHasHigherPriority(E valueA, E valueB) {
    if (priority == Priority.max) {
      return valueA.compareTo(valueB) > 0;
    }
    return valueA.compareTo(valueB) < 0;
  }

  /// Compares two inputs and return index of value with greater
  /// priority.
  ///
  /// Compares the values at two specific indices in the list.
  int _higherPriority(int indexA, int indexB) {
    if (indexA >= elements.length) return indexB; //?
    final valueA = elements[indexA];
    final valueB = elements[indexB];
    final isFirst = _firstHasHigherPriority(valueA, valueB);
    return (isFirst) ? indexA : indexB;
  }

  void _swapValue(int indexA, int indexB) {
    final temp = elements[indexA];
    elements[indexA] = elements[indexB];
    elements[indexB] = temp;
  }

  /// The overall complexity of insert is O(log n). Adding an
  /// element to a list take only O(1) while shifting elements
  /// up in a heap takes O(log n)
  void insert(E value) {
    // Add the value to end of list
    elements.add(value);
    // start shifting procedure using the index of the added value
    _shiftUp(elements.length - 1);
  }

  void _shiftUp(int index) {
    var child = index;
    var parent = _parentIndex(child);
    // As long as value has a higher priority that its parent,
    // then you keep swapping it with the next parent value.
    // since you're only concern about priority, this will shift
    // larger values up in the a max-heap and smaller values up
    // in a min-heap.
    // child > 0 is base condition
    while (child > 0 && child == _higherPriority(child, parent)) {
      _swapValue(child, parent);
      child = parent;
      parent = _parentIndex(child);
    }
  }

  void _shiftDown(int index) {
    // Store the parent index to keep track of where you are in the traversal
    var parent = index;
    while (true) {
      // find the indices of the parent's left and right children
      final left = _leftChildIndex(parent);
      final right = _rightChildIndex(parent);
      // The chosen value keep track of which index to swap with
      // the parent. if left value has higher priority then swap
      // with that and even the right has higher priority then
      // this is the chosen one.
      var chosen = _higherPriority(left, parent);
      chosen = _higherPriority(right, chosen);
      // if chosen is still parent, then no more shifting required.
      if (chosen == parent) return;
      // Otherwise, swap chosen with paren, set it as the new paren
      _swapValue(parent, chosen);
      parent = chosen;
    }
  }

  E? remove() {
    // Always check for properties status, If they are null or
    // empty then return from method
    if (isEmpty) return null;
    // Swap the root with last element in the heap
    _swapValue(0, elements.length - 1);
    // remove the last one and copy its value to return it later
    final value = elements.removeLast();
    // The order may be changed, so you must perform a down
    // shift to make sure it conforms to the rules.
    _shiftDown(0);
    return value;
  }

  /// O(log n)
  /// How to know index of the element you want to delete?
  /// Searching for an element in a [Heap]
  E? removeAt(int index) {
    final lastIndex = elements.length - 1;
    // check if the index is within the bounds of the list. if
    // not return null
    if (index < 0 || index > lastIndex) {
      return null;
    }
    // If removing last element in the heap, simply remove it
    // and return its value
    if (index == lastIndex) {
      return elements.removeLast();
    }
    // swap the element with the last element. then remove it
    // and save its value and return in the end
    _swapValue(index, lastIndex);
    final value = elements.removeLast();
    // Perform a down shift and up shift to adjust the heap
    _shiftDown(index);
    _shiftUp(index);
    return value;
  }

  int indexOf(E value, {int index = 0}) {
    // If the index is too big return -1 like indexOf in [List]
    if (index >= elements.length) {
      return -1;
    }
    // This is the optimization part. Check to see if the value
    // you are looking for has a higher priority that the
    // current node at your recursive traversal of the tree.
    // If it has higher priority then it is not need to
    // continue searching because all the other elements has
    // lower priority. For example in max-heap if you are
    // looking for 10, but the current value has 9, there's no
    // use checking all the nodes below 9 because they're just
    // going to be even lower.
    if (_firstHasHigherPriority(value, elements[index])) {
      return -1;
    }
    // If the value you're looking for is equal to the value
    // at index, you found it. return index.
    if (value == elements[index]) {
      return index;
    }
    // recursively search for the value starting from the left
    // child and then on to the right child. if both searches
    // fail, the whole search fails. return -1
    final left = indexOf(value, index: _leftChildIndex(index));
    if (left != -1) return left;
    return indexOf(value, index: _rightChildIndex(index));
  }

  @override
  String toString() => elements.toString();
}

void main() {
  // var heap = Heap(elements: [1, 12, 3, 4, 1, 6, 8, 7], priority: Priority.min);
  // print(heap);
  // while (!heap.isEmpty) {
  //   print(heap.remove());
  // }
  final integers = [3, 10, 18, 5, 21, 100];
  createAndPrintMinHeap(integers);
}

/// Exercise1: find the n-th smallest integer in an unsorted list
///   final integers = [3, 10, 18, 5, 21, 100];
///   print(findNthSmallest(integers, 3)); //print 10
E findNthSmallest<E extends Comparable<dynamic>>(List<E> list, int nth) {
  final minHeap = Heap(elements: list, priority: Priority.min);
  return minHeap.elements[nth];
}

// returns nth smallest integer in an unsorted list.
int? getNthSmallestElement(int n, List<int> elements) {
  var heap = Heap(elements: elements, priority: Priority.min);
  // use null value cause it may not return a value
  int? value;
  for (int i = 0; i < n; i++) {
    value = heap.remove();
  }
  return value;
}

/// Exercise 2: visually construct a min-heap. Provide a step-by-step diagram of how the min-heap is formed.
void createAndPrintMinHeap<E extends Comparable<dynamic>>(List<E> list) {
  final heap = Heap(elements: list, priority: Priority.min);
  var result = [];
  final temp = heap.elements.length;
  for (int index = 0; index < temp; index++) {
    result.add(heap.remove());
    print(result);
  }
}

/// Write a method that combines two heaps.
Heap combineTwoHeap(Heap a, Heap b) {
  final aElements = a.elements;
  final priority = a.priority;
  final bElements = b.elements;
  aElements.addAll(bElements);
  return Heap(elements: aElements, priority: priority);
}

/// Write a function to check if a given list is a min-heap.
bool isMinHeap(Heap heap) => heap.priority == Priority.min;

/// To satisfy the min-heap requirement, every parent node must
/// be less than or equal to its left and right child
/// O(n) because you still have to check the value of every
/// element in the list.
bool isMeanHeap<E extends Comparable<dynamic>>(List<E> elements) {
  // 1. If the list is empty, it’s a min-heap!
  if (elements.isEmpty) return true;
  // 2. Loop through all parent nodes in the list in reverse order.
  final start = elements.length ~/ 2 - 1;
  for (var index = start; index >= 0; index--) {
    // 3. Get the left and right child index.
    final leftIndex = 2 * index + 1;
    final rightIndex = 2 * index + 2;
    // 4. Check to see if the left element is less than the parent.
    // In a min-heap every parent should be less than or equal
    // to parent, If it's not then return false.
    if (elements[leftIndex].compareTo(elements[index]) < 0) {
      return false;
    }
    // 5. Check to see if the right index is within the list’s bounds, and then check if the
    // right element is less than the parent.
    if (rightIndex < elements.length &&
        elements[rightIndex].compareTo(elements[index]) < 0) {
      return false;
    }
  }
  // 6. If every parent-child relationship satisfies the min-heap property, return true.
  return true;
}
