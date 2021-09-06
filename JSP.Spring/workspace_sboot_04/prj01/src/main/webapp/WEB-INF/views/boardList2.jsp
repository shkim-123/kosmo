<!-- ************************************************************* -->
<!-- JSP 기술의 한 종류인 [Page Directive]를 이용하여 현 JSP 페이지 처리 방식 선언하기 -->
<!-- ************************************************************* -->

<!-- 현재 이 JSP 페이지 실행 후 생성되는 문서는 HTML 이고, 이 문서 안의 데이터는 UTF-8 방식으로 인코딩한다 라고 설정함  -->
<!-- 현재 이 JSP 페이지는 UTF-8 방식으로 인코딩 한다. -->
<!-- UTF-8 인코딩 방식은 한글을 포함 전 세계 모든 문자열을 부호화할 수 있는 방법이다. -->
<!-- 모든 JSP 페이지 상단에는 무조건 아래 설정이 들어간다. -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- ************************************************************* -->
<!-- 현재 JSP 페이지에서 사용할 클래스 수입하기 -->
<!-- ************************************************************* -->
<%@page import="java.util.Map"%>
<%@page import="java.util.List"%>

<!-- ************************************************************* -->
<!-- JSP 기술의 한 종류인 [Include Directive]를 이용하여 common.jsp 파일 내의 소스를 삽입하기 -->
<!-- ************************************************************* -->
<%@include file="common.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<script>

	$(document).ready(function(){
		$(".day").click(function(){
			var checked = $(".day").filter(":checked").val();
			searchExe();
		});
	});

	//--------------------------------------------------------------
	// [페이지 번호]를 클릭하면 호출되는 함수 선언
	//--------------------------------------------------------------
	function search_with_changePageNo(selectPageNo){
		//--------------------------------------------------------------
		// class="selectPageNo" 를 가진 입력양식에 클릭한(=선택한) 페이지 번호를 value 값으로 삽입하기
		// 왜? 서버로 데이터를 보내려고
		//--------------------------------------------------------------
		$(".selectPageNo").val(selectPageNo);
		//--------------------------------------------------------------
		// search 함수 호출하기
		//--------------------------------------------------------------
		search();
	}

	//--------------------------------------------------------------
	// 새글쓰기 클릭하면 호출되는 함수 선언 
	//--------------------------------------------------------------
	function goBoardRegForm(){
		//--------------------------------------------------------------
		// Location 객체의 replace() 메소드 호출로 [새글쓰기 화면]으로 이동하기
		//--------------------------------------------------------------
		// 이 이동방법은 form 태그를 이용한 웹서버 접속 방법이 아니므로 
		// 파라미터값을 가지고 가려면 URL 주소 뒷부분에 ?파라미터명=파라미터값을 붙여야만 한다.
		// 즉, get 방식으로 웹서버에 접속하는 방법이다.
		// 파라미터값이 필요없거나, 파라미터값에 보안성이 필요없을 때 get 방식을 사용한다.
		//--------------------------------------------------------------
		location.replace("/boardRegForm.do");
	}

	//--------------------------------------------------------------
	// 게시판 목록에서 행을 클릭할 경우 호출되는 함수 선언
	// 매개변수로 클릭한 행의 PK 값 즉, b_no 컬럼값이 전달된다.
	//--------------------------------------------------------------
	function goBoardContentForm(b_no){

		//--------------------------------------------------------------
		// name="boardContentForm" 가진 form 태그 내부의 name="b_no" 가진
		// 입력 양식에 클릭한 행의 게시판 번호 저장하기
		//--------------------------------------------------------------
		$("[name='boardContentForm'] [name='b_no']").val(b_no); 

		//--------------------------------------------------------------
		// name="boardContentForm" 가진 form 태그 내부의 action 값의 URL 주소로 서버에 접속하기
		// 즉, 상세보기 화면으로 이동하기
		//--------------------------------------------------------------
		// form 태그를 이용한 웹서버 접속 방법
		// post 방식을 사용할 수 있어서, 파라미터값을 숨겨서 웹서버에 접근할 수 있다.(보안성)
		//--------------------------------------------------------------
		document.boardContentForm.submit();
		
	}

	//--------------------------------------------------------------
	// [검색] 버튼 클릭하면 호출되는 함수 선언
	//--------------------------------------------------------------
	function search(){
		//--------------------------------------------------------------
		// 입력한 키워드 얻어오기
		//--------------------------------------------------------------
		var keyword1 = $(".keyword1").val();

		//--------------------------------------------------------------
		// 만약 키워드가 비어있거나 공백으로 구성되어 있으면 "" 로 대체하기
		//--------------------------------------------------------------
		if( keyword1 == null || keyword1.split(" ").join("") == "" ){
			// alert("키워드를 입력해주세요.");
			// $(".keyword1").val("");
			keyword1 = "";
			// return;
		}

		//--------------------------------------------------------------
		// 입력한 키워드의 앞 뒤 공백 제거하고 다시 입력 양식에 넣어주기
		//--------------------------------------------------------------
		$(".keyword1").val($.trim(keyword1));
		
		//--------------------------------------------------------------
		// 비동기 방식으로 웹서버에 접속하여 키워드를 만족하는 
		// 검색 결과물을 응답받아 현 화면에 반영하기
		//--------------------------------------------------------------
		searchExe();
	}

	//--------------------------------------------------------------
	// [모두 검색] 버튼을 클릭하면 호출되는 함수 선언
	//--------------------------------------------------------------
	function searchAll(){
		//--------------------------------------------------------------
		// 키워드 입력 양식의 value값을 ""로 대체하기
		//--------------------------------------------------------------
		$(".keyword1").val("");
		$(".keyword2").val("");

		//--------------------------------------------------------------
		// class="day"를 가진 입력 양식의 체크 풀기
		//--------------------------------------------------------------
		$(".day").prop("checked", false);
		
		//--------------------------------------------------------------
		// 비동기 방식으로 웹서버에 접속하는 searchExe() 함수 호출하기
		//--------------------------------------------------------------
		searchExe();
	}

	//--------------------------------------------------------------
	// 비동기 방식으로 웹서버에 접속하는 메소드 선언
	//--------------------------------------------------------------
	function searchExe(){

		console.log("serialize => " + $("[name='boardListForm']").serialize());
		
		//--------------------------------------------------------------
		// 현재 화면에서 페이지 이동 없이(=비동기 방식으로)
		// 서버쪽 /boardList.do 로 접속하여 키워드를 만족하는
		// 검색 결과물을 응답받아 현 화면에 반영하기
		//--------------------------------------------------------------
		// 비동기 방식을 사용하는 이유: 현재 화면에서 일부분만 DB 연동 결과물로 변경하기 위하여
		//--------------------------------------------------------------
		$.ajax({
			//--------------------------------------------------------------
			// 서버 쪽 호출 URL 주소 지정
			//--------------------------------------------------------------
			url: "/boardList.do"
			//--------------------------------------------------------------
			// form 태그 안의 입력양식 데이터 즉, 파라미터값을 보내는 방법 지정
			//--------------------------------------------------------------
			,type: "post"
			//--------------------------------------------------------------
			// 서버로 보낼 파라미터명과 파라미터값을 설정
			//--------------------------------------------------------------
			,data: $("[name='boardListForm']").serialize()
			//--------------------------------------------------------------
			// 서버의 응답을 성공적으로 받았을 경우 실행할 익명함수 설정
			// 익명함수의 매개변수에는 서버가 보내온 html 소스가 문자열로 들어온다
			// 즉, 응답메시지 안의 html 소스가 문자열로써 익명함수의 매개변수로 들어온다.
			// 응답메시지 안의 html 소스는 boardList.jsp 의 실행 결과물이다.
			//--------------------------------------------------------------
			,success: function(responseHtml){

				//--------------------------------------------------------------
				// 매개변수 responseHtml로 들어온 검색 결과물 html 소스문자열에서 
				// class="searchResult"를 가진 태그 내부의 [검색 결과물 html 소스]를 얻어서
				// 아래 현 화면의 html 소스 중에 class="searchResult" 를 가진 태그 내부에 덮어씌우기
				//--------------------------------------------------------------
				$(".searchResult").html($(responseHtml).find(".searchResult").html());

				//--------------------------------------------------------------
				// 매개변수 responseHtml로 들어온 검색 결과물 html 소스문자열에서 
				// class="boardListAllCnt"를 가진 태그 내부의 [총개수 문자열]을 얻어서
				// 아래 현 화면의 html 소스 중에 class="boardListAllCnt" 를 가진 태그 내부에 덮어씌우기
				//--------------------------------------------------------------
				$(".boardListAllCnt").html($(responseHtml).find(".boardListAllCnt").text());

				//--------------------------------------------------------------
				// 매개변수 responseHtml로 들어온 검색 결과물 html 소스문자열에서 
				// class="pageNo"를 가진 태그 내부의 [페이지 번호]를 얻어서
				// 아래 현 화면의 html 소스 중에 class="pageNo" 를 가진 태그 내부에 덮어씌우기
				//--------------------------------------------------------------
				$(".pageNo").html($(responseHtml).find(".pageNo").html());
				
			}
			//--------------------------------------------------------------
			// 서버의 응답을 못 받았을 경우 실행할 익명함수 설정
			//--------------------------------------------------------------
			,error: function(){
				alert("서버 접속 실패!");
			}		
		});

	}

</script>

</head>
<!-- ************************************************************* -->
<!-- body 태그 선언하기 -->
<!-- body 태그에 keydown 이벤트를 걸면 특정 태그에 가는 포커스 상관없이 -->
<!-- 무조건 화면에서 키보드 누르면 자스 코드를 실행하게 할 수 있다. -->
<!-- class="keyword1" 인풋 태그 포커스 아웃인 상태에서도 이벤트 실행하고 싶다면 body 태그 안에다 이벤트를 넣어주면 된다.  -->
<!-- ************************************************************* -->
<body onKeydown="if(event.keyCode==13){search();}">

<center>

		
	<!-- ************************************************************* -->
	<!-- 자바 변수 선언하고 검색 화면 구현에 필요한 데이터 꺼내서 저장하기 -->
	<!-- 검색 결과물, 검색된 총 개수, 페이지 번호에 관련된 데이터이다. -->
	<!-- ************************************************************* -->
	<%
		/*
		//--------------------------------------------------------------
		// HttpServletRequest 객체의 setAttribute 메소드 "boardList" 라는 키값으로 저장된 데이터 꺼내기
		//--------------------------------------------------------------
		// "/boardList.do" 로 접속하면 호출되는 메소드 안에서 ModelAndView 객체의 addObject로 저장된 데이터는
		// HttpServletRequest 객체의 setAttribute 메소드로도 저장된 효과를 본다.
		// getAttribute() 의 리턴형은 Object 이므로 형 변환을 꼭 해야 한다.
		//--------------------------------------------------------------
		List<Map<String, String>> boardList = (List<Map<String, String>>)request.getAttribute("boardList");
		//--------------------------------------------------------------
		// HttpServletRequest 객체의 setAttribute 메소드 "boardListAllCnt" 라는 키값으로 저장된 데이터 꺼내기 
		// HttpServletRequest 객체의 setAttribute 메소드 "selectPageNo" 라는 키값으로 저장된 데이터 꺼내기 
		// HttpServletRequest 객체의 setAttribute 메소드 "rowCntPerPage" 라는 키값으로 저장된 데이터 꺼내기 
		// HttpServletRequest 객체의 setAttribute 메소드 "last_pageNo" 라는 키값으로 저장된 데이터 꺼내기 
		// HttpServletRequest 객체의 setAttribute 메소드 "min_pageNo" 라는 키값으로 저장된 데이터 꺼내기 
		// HttpServletRequest 객체의 setAttribute 메소드 "max_pageNo" 라는 키값으로 저장된 데이터 꺼내기 
		//--------------------------------------------------------------
		int boardListAllCnt = (Integer)request.getAttribute("boardListAllCnt");
		int selectPageNo = (Integer)request.getAttribute("selectPageNo");
		int rowCntPerPage= (Integer)request.getAttribute("rowCntPerPage");
		int last_pageNo = (Integer)request.getAttribute("last_pageNo");
		int min_pageNo = (Integer)request.getAttribute("min_pageNo");
		int max_pageNo = (Integer)request.getAttribute("max_pageNo");
		*/
	%>

	<!-- ************************************************************* -->
	<!-- [게시판 검색 조건 입력 양식] 내포한 form 태그 선언 -->
	<!-- form 태그 내에 input 태그가 1개인 경우 엔터 시 웹브라우저는 자동으로 웹서버에 접근을 시도한다.(동기방식, 웹브라우저의 오지랖...) -->
	<!-- 위와 같은 기능을 막는 방법 -->
	<!-- onSubmit = "return false;" : 웹서버로 접근을 시도하는 이벤트 발생 시 자스코딩을 실행하여 웹서버 접근 무력화 -->
	<!-- true 라면 웹서버에 접근, false라면 웹서버에 접근하지 못한다. -->
	<!-- ************************************************************* -->
	<form name="boardListForm" onSubmit="return false;">
		<!-- ------------------------------------------------------------- -->
		<!-- 키워드 데이터 저장하는 입력양식 선언 -->
		<!-- ------------------------------------------------------------- -->
		[키워드] : 
		<input type="text" name="keyword1" class="keyword1">
		<select name="orAnd">
			<option value="or">or</option>
			<option value="and">and</option>
		</select>
		<input type="text" name="keyword2" class="keyword2">
		
		<input type="checkbox" name="day" class="day" value="오늘">오늘
		<input type="checkbox" name="day" class="day" value="어제">어제
		<input type="checkbox" name="day" class="day" value="그제">그제
		<input type="checkbox" name="day" class="day" value="일주일내">일주일내
		
		<!-- ------------------------------------------------------------- -->
		<!-- 선택한(=클릭한) 페이지번호를 저장할 hidden 입력양식 선언 -->
		<!-- 페이징 처리 관련 데이터이다. -->
		<!-- ------------------------------------------------------------- -->
		<input type="hidden" name="selectPageNo" class="selectPageNo" value="1">
		
		<!-- ------------------------------------------------------------- -->
		<!-- 한 화면에 보여줄 검색 결과물 행의 개수 입력양식 선언 -->
		<!-- 페이징 처리 관련 데이터이다. -->
		<!-- ------------------------------------------------------------- -->
		<select name="rowCntPerPage" class="rowCntPerPage" onChange="search();">
			<option value="10">10</option>			
			<option value="15">15</option>			
			<option value="20" selected>20</option>			
			<option value="25">25</option>			
			<option value="30">30</option>			
		</select> 행보기
		
		<!-- ------------------------------------------------------------- -->
		<input type="button" value="검색" class="boardSearch" onClick="search();">&nbsp;
		<input type="button" value="모두검색" class="boardSearchAll" onClick="searchAll();">&nbsp;	
		<!-- ------------------------------------------------------------- -->
			
		<!-- ------------------------------------------------------------- -->
		<!-- href="javascript:자바스크립트코드" 클릭 시 코딩한 자바스크립트코드를 실행한다. -->
		<!-- ------------------------------------------------------------- -->
		<a href="javascript:goBoardRegForm();">새글쓰기</a>
	</form>
	
	<!-- ------------------------------------------------------------- -->
	<!-- div 태그를 이용하여 위아래 콘텐츠 사이 여백 주기 -->
	<!-- ------------------------------------------------------------- -->
	<div style="height:10px"></div>
	
<%-- 	<div class="boardListAllCnt">총 : <%//=boardListAllCnt%>개</div> --%>
	
	<!-- ------------------------------------------------------------- -->
	<!-- 검색된 목록의 총 개수 출력하기 -->
	<!-- ------------------------------------------------------------- -->
	<!-- EL(=Expression Language)을 사용하여 HttpServletRequest 객체에 -->
	<!-- setAttribute 메소드로 저장된 키값 "boardListAllCnt"의 데이터를 꺼내서 표현하기 -->
	<!-- <참고> EL은 JSP 페이지에서 사용 가능한 언어이다. 즉, EL은 JSP 기술의 한 종류이다. -->
	<!-- ------------------------------------------------------------- -->
	<div class="boardListAllCnt">총 : ${requestScope.boardListAllCnt}개</div>
	
	<div class="searchResult">
		<table border="1">
			<tr>
				<th>번호</th>
				<th>제목</th>
				<th>작성자</th>
				<th>조회수</th>
				<th>등록일</th>
			</tr>
			
			
			<%
				/*
				// 주석 작성 시 코딩적 주석과 기능적 주석을 구분하면 좋음
				//--------------------------------------------------------------
				// 코딩적 주석: boardList가 null이 아니면, 기능적 주석: 검색결과물이 있으면
				//--------------------------------------------------------------
				if( boardList != null ) {
					
					//--------------------------------------------------------------
					// 선택한 페이지 번호에 맞는 검색 결과물의 시작 정순번호 구하기
					// 선택한 페이지 번호에 맞는 검색 결과물의 시작 역순번호 구하기
					//--------------------------------------------------------------
					int serialNo_asc = selectPageNo*rowCntPerPage-rowCntPerPage+1;
					int serialNo_desc = boardListAllCnt - (selectPageNo*rowCntPerPage-rowCntPerPage+1) + 1;
					
					//--------------------------------------------------------------
					// 기능적 주석: 검색결과물을 HTML 태그로 출력하기
					// 코딩적 주석: boardList 안의 ArrayList 객체에 들어 있는 다량의 HashMap 객체를 꺼내어 
					// HashMap 객체 안의 키값에 대응하는 문자를 꺼내어 HTML 태그로 출력하기
					//--------------------------------------------------------------
					for( int i = 0; i < boardList.size(); i++ ) {
						
						//--------------------------------------------------------------
						// i번째 HashMap 객체를 꺼내기 
						//--------------------------------------------------------------
						Map<String,String> map = boardList.get(i);
						
						//--------------------------------------------------------------
						// i번째 HashMap 객체에 키값 B_NO 에 대응하는 저장 문자열 꺼내기 
						// i번째 HashMap 객체에 키값 SUBJECT 에 대응하는 저장 문자열 꺼내기 
						// i번째 HashMap 객체에 키값 WRITER 에 대응하는 저장 문자열 꺼내기 
						// i번째 HashMap 객체에 키값 READCOUNT 에 대응하는 저장 문자열 꺼내기 
						// i번째 HashMap 객체에 키값 REG_DATE 에 대응하는 저장 문자열 꺼내기 
						// i번째 HashMap 객체에 키값 PRINT_LEVEL 에 대응하는 저장 문자열 꺼내기 
						//--------------------------------------------------------------
						int b_no = Integer.parseInt(map.get("B_NO"), 10);
						String subject = map.get("SUBJECT");
						String writer = map.get("WRITER");
						String readcount = map.get("READCOUNT");
						String reg_date = map.get("REG_DATE");
						int print_level = Integer.parseInt(map.get("PRINT_LEVEL"), 10);
						
						//--------------------------------------------------------------
						// 들여쓰기 단계 번호에 맞게 공백을 누적하고 들여쓰기 단계가 1 이상이면 ㄴ자 붙이기
						//--------------------------------------------------------------
						String blank = "";
						for(int j=0; j < print_level; j++){
							blank += "&nbsp&nbsp&nbsp";
						}
						if(print_level > 0) { blank = blank + "ㄴ"; }
						
						//--------------------------------------------------------------
						// HTML 또는 문자열로 표현하기
						//--------------------------------------------------------------
						out.println( "<tr style='cursor:pointer' onClick='goBoardContentForm("+b_no+")'><td>"
							//	+(serialNo_asc++)
								+(serialNo_desc--)
								+"<td>"+blank+subject
								+"<td>"+writer+"<td>"+readcount+"<td>"+reg_date );
						
					}
				}
			*/
			%>
			
			
		</table> 
	</div>
	
	<div style="height:10px"></div>
	
	<!-- 페이지 번호 출력 -->
	<div class="pageNo">	
		<%		
		/*
			//--------------------------------------------------------------
			// 만약 검색 결과물이 0보다 크면, 즉, 검색 결과물이 있으면
			//--------------------------------------------------------------
			if( boardListAllCnt > 0 ){
				
				
				// 이전, 다음 선택 시 페이지 번호가 10단위로 변경
				if(min_pageNo > 10){
					out.print( "<span style='cursor:pointer' onClick='search_with_changePageNo("+ (min_pageNo-1) + ");'>[이전]</span> ");
				}
				
				for(int i = min_pageNo; i <= max_pageNo; i++){
					if(selectPageNo == i){
						out.print( "<span>"+ i + "</span> ");
					} else {
						out.print( "<span style='cursor:pointer' onClick='search_with_changePageNo("+i+");'>["+ i + "]</span> ");
					}
				}
				
				if(max_pageNo < last_pageNo){
					out.print( "<span style='cursor:pointer' onClick='search_with_changePageNo("+ (max_pageNo+1) + ");'>[다음]</span> ");
				}
				
				
				//--------------------------------------------------------------
				// 이전, 다음 선택 시 페이지 번호가 1씩 변경
				// 선택한 페이지 번호가 1보다 크면 [처음], [이전] 글씨 보이기. 단, 클릭하면 함수 호출하도록 클릭이벤트 걸기
				//--------------------------------------------------------------
				if(selectPageNo > 1){
					out.print( "<span style='cursor:pointer' onClick='search_with_changePageNo("+ (1) + ");'>[처음]</span> ");
					out.print( "<span style='cursor:pointer' onClick='search_with_changePageNo("+ (selectPageNo-1) + ");'>[이전]</span> ");
					out.print( "&nbsp;&nbsp;");
				} 
				//--------------------------------------------------------------
				// 선택한 페이지 번호가 1이면 [처음] [이전] 글씨 보이기. 단, 클릭하면 함수 호출하는 이벤트 걸지 말기
				//--------------------------------------------------------------
				else {
					// 처음, 이전을 항상 보여주도록 설정
					out.print( "<span>[처음]</span> ");
					out.print( "<span>[이전]</span> ");
					out.print( "&nbsp;&nbsp;");
				}
				//--------------------------------------------------------------
				// 선택한 페이지 번호에 맞는 페이지 번호들을 출력하기
				//--------------------------------------------------------------
				for(int i = min_pageNo; i <= max_pageNo; i++){
					// 만약 출력되는 페이지 번호와 선택한 페이지 번호가 일치하면 그냥 번호만 표현하기
					if(selectPageNo == i){
						out.print( "<span>"+ i + "</span> ");
					} 
					// 만약, 출력되는 페이지 번호와 선택한 페이지 번호가 일치하지 않으면 클릭하면 함수 호출하도록 클릭이벤트 걸기
					else {
						out.print( "<span style='cursor:pointer' onClick='search_with_changePageNo("+i+");'>["+ i + "]</span> ");
					}
				}
				//--------------------------------------------------------------
				// 선택한 페이지 번호가 마지막 페이지 번호보다 작으면 [다음] [마지막] 문자 표현하기
				// 단, 클릭하면 함수 호출하도록 클릭 이벤트 걸기
				//--------------------------------------------------------------
				if(selectPageNo < last_pageNo){
					out.print( "&nbsp;&nbsp;");
					out.print( "<span style='cursor:pointer' onClick='search_with_changePageNo("+ (selectPageNo+1) + ");'>[다음]</span> ");
					out.print( "<span style='cursor:pointer' onClick='search_with_changePageNo("+ (last_pageNo) + ");'>[마지막]</span> ");
				} 
				//--------------------------------------------------------------
				// 선택한 페이지 번호가 마지막 페이지 번호보다 같으면 [다음] [마지막] 문자만 표현하기
				// 단, 클릭하면 함수 호출하는 이벤트는 걸지 말기
				//--------------------------------------------------------------
				else {
					// 다음, 마지막을 항상 보여주도록 설정
					out.print( "<span>[다음]</span> ");
					out.print( "<span>[마지막]</span> ");
					out.print( "&nbsp;&nbsp;");
				}
				
			}
			*/
		%>
		
		<c:if test="${requestScope.boardListAllCnt>0}">
		
			<c:if test="${requestScope.selectPageNo>1}">
				<span style='cursor:pointer' onClick='search_with_changePageNo(1);'>[처음]</span>
				<span style='cursor:pointer' onClick='search_with_changePageNo(${requestScope.selectPageNo}-1);'>[이전]</span>
				&nbsp;&nbsp;
			</c:if>
			
			<c:if test="${requestScope.selectPageNo<=1}">
				<span>[처음]</span>
				<span>[이전]</span>
				&nbsp;&nbsp;
			</c:if>
			
			<c:forEach var="no" begin="${requestScope.min_pageNo}" end="${requestScope.max_pageNo}" step="1">
				<c:if test="${no==requestScope.selectPageNo}">
					<span>${no}</span>
				</c:if>
				
				<c:if test="${no!=requestScope.selectPageNo}">
					<span style="cursor:pointer" onClick="search_with_changePageNo(${no});">[${no}]</span>
				</c:if>
				
			</c:forEach>
			
			<c:if test="${requestScope.selectPageNo<requestScope.last_pageNo}">
				&nbsp;&nbsp;
				<span style='cursor:pointer' onClick='search_with_changePageNo(${requestScope.selectPageNo}+1);'>[다음]</span>
				<span style='cursor:pointer' onClick='search_with_changePageNo(${requestScope.last_pageNo});'>[마지막]</span>
			</c:if>
			
			<c:if test="${requestScope.selectPageNo>=requestScope.last_pageNo}">
				&nbsp;&nbsp;
				<span>[다음]</span>
				<span>[마지막]</span>
			</c:if>
			
		</c:if>
		
	</div>
	
	<!-- ************************************************************* -->
	<!-- 게시판 상세 보기 화면으로 이동하는 form 태그 선언하기 -->
	<!-- form 태그 안에 action 값이 있다면 페이지 이동하겠다는 말이다. -->
	<!-- ************************************************************* -->
	<form name="boardContentForm" method="post" action="/boardContentForm.do">
		<!-- ************************************************************* -->
		<!-- [클릭한 게시판 글의 고유번호]가 저장되는 [hidden 입력 양식] 선언 -->
		<!-- hidden 태그에 어떤 값이 들었는지 모르니까 개발하는 동안 type="text"로 변경하여 편함! -->
		<!-- ************************************************************* -->
		<input type="hidden" name="b_no">
	</form>
		
</center>


</body>
</html>