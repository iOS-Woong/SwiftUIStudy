# 0219 스터디

**과제: Left Aligned TagView**

![image](https://github.com/user-attachments/assets/688c8964-1924-45c9-b08e-08928427f63b)

https://github.com/user-attachments/assets/c4b8072d-429e-4713-b5a9-b864437bc3f4

### 1. 구현

- TagRows라는 2차원 배열을 선언한다.
- 태그를 한줄에 표시할 너비 `나는 화면너비` 를 정의 해준다.
- 한개너비 `[left Padding + 텍스트폰트사이즈 + rightPadding]`  를 정의 해준다.
- 태그에 담길 데이터묶음(”안녕”, “나는”, “태그야”)을 순회시킨다.
    - 순회시키며, tagRows에 0번인덱스(첫줄)에 표시가능한너비인지 체크하고,
    - 공간이 있으면 tagRows[0]에 어펜드
    - 공간이 없으면 tagRows[1]을 만들고 그곳에 어펜드!
- ForEach로 Row별로 태그들을 차곡차곡 쌓는다.
- 태그묶음 값의 변경(추가, 변경, 삭제)가 있을 때, 너비를 재계산하여 뷰를 다시그려준다.

### 2. 불참으로 인해 의견이나 코드 참조 할 수 없었음
