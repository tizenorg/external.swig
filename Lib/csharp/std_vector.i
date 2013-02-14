/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * std_vector.i
 *
 * SWIG typemaps for std::vector<T>
 * C# implementation
 * The C# wrapper is made to look and feel like a C# System.Collections.Generic.List<> collection.
 * For .NET 1 compatibility, define SWIG_DOTNET_1 when compiling the C# code; then the C# wrapper is 
 * made to look and feel like a typesafe C# System.Collections.ArrayList.
 *
 * Note that IEnumerable<> is implemented in the proxy class which is useful for using LINQ with 
 * C++ std::vector wrappers. The IList<> interface is also implemented to provide enhanced functionality
 * whenever we are confident that the required C++ operator== is available. This is the case for when 
 * T is a primitive type or a pointer. If T does define an operator==, then use the SWIG_STD_VECTOR_ENHANCED
 * macro to obtain this enhanced functionality, for example:
 *
 *   SWIG_STD_VECTOR_ENHANCED(SomeNamespace::Klass)
 *   %template(VectKlass) std::vector<SomeNamespace::Klass>;
 *
 * Warning: heavy macro usage in this file. Use swig -E to get a sane view on the real file contents!
 * ----------------------------------------------------------------------------- */

// Warning: Use the typemaps here in the expectation that the macros they are in will change name.


%include <std_common.i>

// MACRO for use within the std::vector class body
%define SWIG_STD_VECTOR_MINIMUM_INTERNAL(CSINTERFACE, CONST_REFERENCE_TYPE, CTYPE...)
%typemap(csinterfaces) std::vector<CTYPE > "IDisposable, System.Collections.IEnumerable\n#if !SWIG_DOTNET_1\n    , System.Collections.Generic.CSINTERFACE<$typemap(cstype, CTYPE)>\n#endif\n";
%typemap(cscode) std::vector<CTYPE > %{
  public $csclassname(System.Collections.ICollection c) : this() {
    if (c == null)
      throw new ArgumentNullException("c");
    foreach ($typemap(cstype, CTYPE) element in c) {
      this.Add(element);
    }
  }

  public bool IsFixedSize {
    get {
      return false;
    }
  }

  public bool IsReadOnly {
    get {
      return false;
    }
  }

  public $typemap(cstype, CTYPE) this[int index]  {
    get {
      return getitem(index);
    }
    set {
      setitem(index, value);
    }
  }

  public int Capacity {
    get {
      return (int)capacity();
    }
    set {
      if (value < size())
        throw new ArgumentOutOfRangeException("Capacity");
      reserve((uint)value);
    }
  }

  public int Count {
    get {
      return (int)size();
    }
  }

  public bool IsSynchronized {
    get {
      return false;
    }
  }

#if SWIG_DOTNET_1
  public void CopyTo(System.Array array)
#else
  public void CopyTo($typemap(cstype, CTYPE)[] array)
#endif
  {
    CopyTo(0, array, 0, this.Count);
  }

#if SWIG_DOTNET_1
  public void CopyTo(System.Array array, int arrayIndex)
#else
  public void CopyTo($typemap(cstype, CTYPE)[] array, int arrayIndex)
#endif
  {
    CopyTo(0, array, arrayIndex, this.Count);
  }

#if SWIG_DOTNET_1
  public void CopyTo(int index, System.Array array, int arrayIndex, int count)
#else
  public void CopyTo(int index, $typemap(cstype, CTYPE)[] array, int arrayIndex, int count)
#endif
  {
    if (array == null)
      throw new ArgumentNullException("array");
    if (index < 0)
      throw new ArgumentOutOfRangeException("index", "Value is less than zero");
    if (arrayIndex < 0)
      throw new ArgumentOutOfRangeException("arrayIndex", "Value is less than zero");
    if (count < 0)
      throw new ArgumentOutOfRangeException("count", "Value is less than zero");
    if (array.Rank > 1)
      throw new ArgumentException("Multi dimensional array.", "array");
    if (index+count > this.Count || arrayIndex+count > array.Length)
      throw new ArgumentException("Number of elements to copy is too large.");
    for (int i=0; i<count; i++)
      array.SetValue(getitemcopy(index+i), arrayIndex+i);
  }

#if !SWIG_DOTNET_1
  System.Collections.Generic.IEnumerator<$typemap(cstype, CTYPE)> System.Collections.Generic.IEnumerable<$typemap(cstype, CTYPE)>.GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }
#endif

  System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }

  public $csclassnameEnumerator GetEnumerator() {
    return new $csclassnameEnumerator(this);
  }

  // Type-safe enumerator
  /// Note that the IEnumerator documentation requires an InvalidOperationException to be thrown
  /// whenever the collection is modified. This has been done for changes in the size of the
  /// collection but not when one of the elements of the collection is modified as it is a bit
  /// tricky to detect unmanaged code that modifies the collection under our feet.
  public sealed class $csclassnameEnumerator : System.Collections.IEnumerator
#if !SWIG_DOTNET_1
    , System.Collections.Generic.IEnumerator<$typemap(cstype, CTYPE)>
#endif
  {
    private $csclassname collectionRef;
    private int currentIndex;
    private object currentObject;
    private int currentSize;

    public $csclassnameEnumerator($csclassname collection) {
      collectionRef = collection;
      currentIndex = -1;
      currentObject = null;
      currentSize = collectionRef.Count;
    }

    // Type-safe iterator Current
    public $typemap(cstype, CTYPE) Current {
      get {
        if (currentIndex == -1)
          throw new InvalidOperationException("Enumeration not started.");
        if (currentIndex > currentSize - 1)
          throw new InvalidOperationException("Enumeration finished.");
        if (currentObject == null)
          throw new InvalidOperationException("Collection modified.");
        return ($typemap(cstype, CTYPE))currentObject;
      }
    }

    // Type-unsafe IEnumerator.Current
    object System.Collections.IEnumerator.Current {
      get {
        return Current;
      }
    }

    public bool MoveNext() {
      int size = collectionRef.Count;
      bool moveOkay = (currentIndex+1 < size) && (size == currentSize);
      if (moveOkay) {
        currentIndex++;
        currentObject = collectionRef[currentIndex];
      } else {
        currentObject = null;
      }
      return moveOkay;
    }

    public void Reset() {
      currentIndex = -1;
      currentObject = null;
      if (collectionRef.Count != currentSize) {
        throw new InvalidOperationException("Collection modified.");
      }
    }

#if !SWIG_DOTNET_1
    public void Dispose() {
        currentIndex = -1;
        currentObject = null;
    }
#endif
  }
%}

  public:
    typedef size_t size_type;
    typedef CTYPE value_type;
    typedef CONST_REFERENCE_TYPE const_reference;
    %rename(Clear) clear;
    void clear();
    %rename(Add) push_back;
    void push_back(const value_type& x);
    size_type size() const;
    size_type capacity() const;
    void reserve(size_type n);
    %newobject GetRange(int index, int count);
    %newobject Repeat(const value_type& value, int count);
    vector();
    vector(const vector &other);
    %extend {
      vector(int capacity) throw (std::out_of_range) {
        std::vector<CTYPE >* pv = 0;
        if (capacity >= 0) {
          pv = new std::vector<CTYPE >();
          pv->reserve(capacity);
       } else {
          throw std::out_of_range("capacity");
       }
       return pv;
      }
      CTYPE getitemcopy(int index) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size())
          return (*$self)[index];
        else
          throw std::out_of_range("index");
      }
      const_reference getitem(int index) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size())
          return (*$self)[index];
        else
          throw std::out_of_range("index");
      }
      void setitem(int index, const value_type& val) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size())
          (*$self)[index] = val;
        else
          throw std::out_of_range("index");
      }
      // Takes a deep copy of the elements unlike ArrayList.AddRange
      void AddRange(const std::vector<CTYPE >& values) {
        $self->insert($self->end(), values.begin(), values.end());
      }
      // Takes a deep copy of the elements unlike ArrayList.GetRange
      std::vector<CTYPE > *GetRange(int index, int count) throw (std::out_of_range, std::invalid_argument) {
        if (index < 0)
          throw std::out_of_range("index");
        if (count < 0)
          throw std::out_of_range("count");
        if (index >= (int)$self->size()+1 || index+count > (int)$self->size())
          throw std::invalid_argument("invalid range");
        return new std::vector<CTYPE >($self->begin()+index, $self->begin()+index+count);
      }
      void Insert(int index, const value_type& x) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size()+1)
          $self->insert($self->begin()+index, x);
        else
          throw std::out_of_range("index");
      }
      // Takes a deep copy of the elements unlike ArrayList.InsertRange
      void InsertRange(int index, const std::vector<CTYPE >& values) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size()+1)
          $self->insert($self->begin()+index, values.begin(), values.end());
        else
          throw std::out_of_range("index");
      }
      void RemoveAt(int index) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size())
          $self->erase($self->begin() + index);
        else
          throw std::out_of_range("index");
      }
      void RemoveRange(int index, int count) throw (std::out_of_range, std::invalid_argument) {
        if (index < 0)
          throw std::out_of_range("index");
        if (count < 0)
          throw std::out_of_range("count");
        if (index >= (int)$self->size()+1 || index+count > (int)$self->size())
          throw std::invalid_argument("invalid range");
        $self->erase($self->begin()+index, $self->begin()+index+count);
      }
      static std::vector<CTYPE > *Repeat(const value_type& value, int count) throw (std::out_of_range) {
        if (count < 0)
          throw std::out_of_range("count");
        return new std::vector<CTYPE >(count, value);
      }
      void Reverse() {
        std::reverse($self->begin(), $self->end());
      }
      void Reverse(int index, int count) throw (std::out_of_range, std::invalid_argument) {
        if (index < 0)
          throw std::out_of_range("index");
        if (count < 0)
          throw std::out_of_range("count");
        if (index >= (int)$self->size()+1 || index+count > (int)$self->size())
          throw std::invalid_argument("invalid range");
        std::reverse($self->begin()+index, $self->begin()+index+count);
      }
      // Takes a deep copy of the elements unlike ArrayList.SetRange
      void SetRange(int index, const std::vector<CTYPE >& values) throw (std::out_of_range) {
        if (index < 0)
          throw std::out_of_range("index");
        if (index+values.size() > $self->size())
          throw std::out_of_range("index");
        std::copy(values.begin(), values.end(), $self->begin()+index);
      }
    }
%enddef

%define SWIG_STD_VECTOR_MINIMUM(CTYPE...)
SWIG_STD_VECTOR_MINIMUM_INTERNAL(IEnumerable, const value_type&, CTYPE)
%enddef

// Extra methods added to the collection class if operator== is defined for the class being wrapped
// The class will then implement IList<>, which adds extra functionality
%define SWIG_STD_VECTOR_EXTRA_OP_EQUALS_EQUALS(CTYPE...)
    %extend {
      bool Contains(const value_type& value) {
        return std::find($self->begin(), $self->end(), value) != $self->end();
      }
      int IndexOf(const value_type& value) {
        int index = -1;
        std::vector<CTYPE >::iterator it = std::find($self->begin(), $self->end(), value);
        if (it != $self->end())
          index = (int)(it - $self->begin());
        return index;
      }
      int LastIndexOf(const value_type& value) {
        int index = -1;
        std::vector<CTYPE >::reverse_iterator rit = std::find($self->rbegin(), $self->rend(), value);
        if (rit != $self->rend())
          index = (int)($self->rend() - 1 - rit);
        return index;
      }
      bool Remove(const value_type& value) {
        std::vector<CTYPE >::iterator it = std::find($self->begin(), $self->end(), value);
        if (it != $self->end()) {
          $self->erase(it);
	  return true;
        }
        return false;
      }
    }
%enddef

// Macros for std::vector class specializations/enhancements
%define SWIG_STD_VECTOR_ENHANCED(CTYPE...)
namespace std {
  template<> class vector<CTYPE > {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(IList, const value_type&, CTYPE)
    SWIG_STD_VECTOR_EXTRA_OP_EQUALS_EQUALS(CTYPE)
  };
}
%enddef

// Legacy macros
%define SWIG_STD_VECTOR_SPECIALIZE(CSTYPE, CTYPE...)
#warning SWIG_STD_VECTOR_SPECIALIZE macro deprecated, please see csharp/std_vector.i and switch to SWIG_STD_VECTOR_ENHANCED
SWIG_STD_VECTOR_ENHANCED(CTYPE)
%enddef

%define SWIG_STD_VECTOR_SPECIALIZE_MINIMUM(CSTYPE, CTYPE...)
#warning SWIG_STD_VECTOR_SPECIALIZE_MINIMUM macro deprecated, it is no longer required
%enddef

%{
#include <vector>
#include <algorithm>
#include <stdexcept>
%}

%csmethodmodifiers std::vector::getitemcopy "private"
%csmethodmodifiers std::vector::getitem "private"
%csmethodmodifiers std::vector::setitem "private"
%csmethodmodifiers std::vector::size "private"
%csmethodmodifiers std::vector::capacity "private"
%csmethodmodifiers std::vector::reserve "private"

namespace std {
  // primary (unspecialized) class template for std::vector
  // does not require operator== to be defined
  template<class T> class vector {
    SWIG_STD_VECTOR_MINIMUM(T)
  };
  // specializations for pointers
  template<class T> class vector<T*> {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(IList, const value_type&, T*)
    SWIG_STD_VECTOR_EXTRA_OP_EQUALS_EQUALS(T*)
  };
  template<class T> class vector<const T*> {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(IList, const value_type&, const T*)
    SWIG_STD_VECTOR_EXTRA_OP_EQUALS_EQUALS(const T*)
  };
  // bool is a bit different in the C++ standard
  template<> class vector<bool> {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(IList, bool, bool)
    SWIG_STD_VECTOR_EXTRA_OP_EQUALS_EQUALS(bool)
  };
}

// template specializations for std::vector
// these provide extra collections methods as operator== is defined
SWIG_STD_VECTOR_ENHANCED(char)
SWIG_STD_VECTOR_ENHANCED(signed char)
SWIG_STD_VECTOR_ENHANCED(unsigned char)
SWIG_STD_VECTOR_ENHANCED(short)
SWIG_STD_VECTOR_ENHANCED(unsigned short)
SWIG_STD_VECTOR_ENHANCED(int)
SWIG_STD_VECTOR_ENHANCED(unsigned int)
SWIG_STD_VECTOR_ENHANCED(long)
SWIG_STD_VECTOR_ENHANCED(unsigned long)
SWIG_STD_VECTOR_ENHANCED(long long)
SWIG_STD_VECTOR_ENHANCED(unsigned long long)
SWIG_STD_VECTOR_ENHANCED(float)
SWIG_STD_VECTOR_ENHANCED(double)
SWIG_STD_VECTOR_ENHANCED(std::string) // also requires a %include <std_string.i>

