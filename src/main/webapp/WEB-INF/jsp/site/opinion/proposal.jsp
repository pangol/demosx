<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="discussion-comment-form" id="discussion-comment-form">
  <c:if test="${param.closed eq true}">
    <h4><b>토론 기간동안 댓글 작성이 가능합니다.</b> (${debate.startDate} ~ ${debate.endDate})</h4>
  </c:if>
  <c:if test="${param.closed ne true}">
  <div class="demo-comment-form clearfix">
    <c:if test="${empty loginUser}">
      <div class="profile-circle profile-circle--comment-form" style="background-image: url(/images/noavatar.png)">
        <p class="alt-text">기본프로필</p>
      </div>
      <form>
        <textarea class="form-control demo-comment-textarea" rows="5" placeholder="로그인 후 댓글을 달 수 있습니다."
                  disabled></textarea>
        <div class="comment-action-group row">
          <div class="comment-count col-xs-6"><p class="comment-count-text">0/1000자</p></div>
          <div class="comment-submit text-right col-xs-6">
            <button type="button" class="demo-submit-btn demo-submit-btn--submit pull-right show-login-modal">댓글달기
            </button>
          </div>
        </div>
      </form>
    </c:if>
    <c:if test="${not empty loginUser}">
      <div class="profile-circle profile-circle--comment-form" style="background-image: url(${loginUser.viewPhoto()})">
        <p class="alt-text">${loginUser.name}프로필</p>
      </div>
      <form id="form-opinion">
        <input type="hidden" name="issueId" value="${param.id}">
        <input type="hidden" name="vote" value="ETC">
        <div class="form-group">
          <textarea class="form-control demo-comment-textarea" rows="5" name="content"
                    data-parsley-required="true" data-parsley-maxlength="1000"></textarea>
        </div>
        <div class="comment-action-group row">
          <div class="comment-count col-xs-6"><p class="comment-count-text"><span id="opinion-length">0</span>/1000자</p>
          </div>
          <div class="comment-submit text-right col-xs-6">
            <button type="submit" class="demo-submit-btn demo-submit-btn--submit pull-right">댓글달기
            </button>
          </div>
        </div>
      </form>
    </c:if>
  </div>
  </c:if>
</div>

<c:if test="${not empty loginUser}">
  <div class="modal fade" id="modalEditOpinion" tabindex="-1" role="dialog" aria-labelledby="의견 수정하기">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-body">
          <form class="demo-form" id="form-edit-opinion">
            <input type="hidden" name="opinionId" value="">
            <div class="form-input-container form-input-container--history">
              <div class="form-group form-group--demo">
                <label class="demo-form-label" for="inputContent">의견 수정하기</label>
                <textarea class="form-control" name="content" id="inputContent" rows="8"
                          data-parsley-required="true" data-parsley-maxlength="1000"></textarea>
              </div>
            </div>
            <div class="form-action text-right">
              <div class="btn-group clearfix">
                <button class="btn demo-submit-btn cancel-btn" data-dismiss="modal" aria-label="Close" role="button">취소
                </button>
                <button type="submit" class="demo-submit-btn demo-submit-btn--submit">저장하기</button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</c:if>

<div class="demo-comments-container">
  <div class="demo-comments-top">
    <div class="clearfix">
      <div class="demo-comments-top__tabs demo-comments-top__tabs--discuss">
        <ul class="comment-sorting-ul clearfix">
          <li class="comment-sorting-li active">
            <a class="sorting-link opinion-sort" id="latest-sort-btn" data-sort="createdDate,desc" href="#">최신순</a>
          </li>
          <li class="comment-sorting-li">
            <a class="sorting-link opinion-sort" data-sort="createdDate,asc" href="#">과거순</a>
          </li>
          <li class="comment-sorting-li">
            <a class="sorting-link opinion-sort" data-sort="likeCount,desc" href="#">공감순</a>
          </li>
        </ul>
      </div>
    </div>
  </div>
  <ul class="demo-comments" id="opinion-list"></ul>
  <div class="comment-end-line"></div>
  <div class="show-more-container text-center">
    <button class="white-btn d-btn btn-more" type="button" id="opinion-more">더보기<i class="xi-angle-down-min"></i>
    </button>
  </div>
</div>

<!-- jquery serialize object -->
<script type="text/javascript"
        src="https://cdnjs.cloudflare.com/ajax/libs/jquery-serialize-object/2.5.0/jquery.serialize-object.min.js"></script>
<script>
  <c:if test="${not empty loginUser}">
  $(function () {
    // 의견 등록
    var $opinionLength = $('#opinion-length');
    $('textarea[name=content]').keyup(function () {
      $opinionLength.text($(this).val().length);
    });

    var $formOpinion = $('#form-opinion');
    $formOpinion.parsley(parsleyConfig);
    $formOpinion.on('submit', function (event) {
      event.preventDefault();

      var data = $formOpinion.serializeObject();
      $.ajax({
        headers: { 'X-CSRF-TOKEN': '${_csrf.token}' },
        url: '/ajax/mypage/opinions',
        type: 'POST',
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify(data),
        success: function (data) {
          alert(data.msg);
          $('#latest-sort-btn').trigger('click');
          $formOpinion[0].reset();
          $formOpinion.parsley().reset();
        },
        error: function (error) {
          if (error.status === 400) {
            if (error.responseJSON.fieldErrors) {
              var msg = error.responseJSON.fieldErrors.map(function (item) {
                return item.fieldError;
              }).join('/n');
              alert(msg);
            } else alert(error.responseJSON.msg);
          } else if (error.status === 403 || error.status === 401) {
            alert('로그인이 필요합니다.');
            window.location.href = '/login.do';
          }
        }
      });
    });

    <%--// 의견 삭제
    $(document).on('click', '.delete-opinion-btn', function () {
      if (!window.confirm('삭제할까요?')) return;

      var id = $(this).data('id');

      var that = this;
      $.ajax({
        headers: { 'X-CSRF-TOKEN': '${_csrf.token}' },
        url: '/ajax/mypage/opinions/' + id,
        type: 'DELETE',
        contentType: 'application/json',
        dataType: 'json',
        success: function (data) {
          alert(data.msg);
          $(that).parents('.comment-li').remove();
        },
        error: function (error) {
          if (error.status === 400) {
            if (error.responseJSON.fieldErrors) {
              var msg = error.responseJSON.fieldErrors.map(function (item) {
                return item.fieldError;
              }).join('/n');
              alert(msg);
            } else alert(error.responseJSON.msg);
          } else if (error.status === 401) {
            alert('로그인이 필요합니다.');
            window.location.href = '/login.do';
          } else if (error.status === 403) {
            alert('삭제할 수 없습니다.');
          }
        }
      });
    });--%>

    // 의견 수정
    var $opinionContent = null;
    var $modalEditOpinion = $('#modalEditOpinion');
    $(document).on('click', '.edit-opinion-btn', function() {
      $formOpinion[0].reset();
      $formOpinion.parsley().reset();
      $opinionContent = $(this).parents('.comment-li');
      $('input[name=opinionId]', $modalEditOpinion).val($(this).data('id'));
      $('textarea[name=content]', $modalEditOpinion).val($(this).data('content'));
      $modalEditOpinion.modal('show');
    });
    var $formEditOpinion = $('#form-edit-opinion');
    $formEditOpinion.parsley(parsleyConfig);
    $formEditOpinion.on('submit', function (event) {
      event.preventDefault();
      var data = $formEditOpinion.serializeObject();
      $.ajax({
        headers: { 'X-CSRF-TOKEN': '${_csrf.token}' },
        url: '/ajax/mypage/opinions/' + data.opinionId,
        type: 'PUT',
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify(data),
        success: function (result) {
          alert(result.msg);
          $('.comment-content-text', $opinionContent).html(data.content.replace(/\r\n|\r|\n|\n\r/g, '<br>'));
          $modalEditOpinion.modal('hide');
        },
        error: function (error) {
          if (error.status === 400) {
            if (error.responseJSON.fieldErrors) {
              var msg = error.responseJSON.fieldErrors.map(function (item) {
                return item.fieldError;
              }).join('/n');
              alert(msg);
            } else alert(error.responseJSON.msg);
          } else if (error.status === 403 || error.status === 401) {
            alert('로그인이 필요합니다.');
            window.location.href = '/login.do';
          }
        }
      });
    });

    // 의견 공감
    $(document).on('click', '.opinion-thumbs-up-btn', function () {
      var hasLike = $(this).hasClass('active');
      var id = $(this).data('id');
      var that = $(this);
      $.ajax({
        headers: { 'X-CSRF-TOKEN': '${_csrf.token}' },
        url: '/ajax/mypage/opinions/' + id + '/' + (hasLike ? 'deselectLike' : 'selectLike'),
        type: 'PUT',
        contentType: 'application/json',
        dataType: 'json',
        success: function (data) {
          alert(data.msg);
          var count = +$('strong', that).text();
          if (hasLike) {
            that.removeClass('active');
            if (count !== 0) $('strong', that).text(count - 1);
          }
          else {
            that.addClass('active');
            $('strong', that).text(count + 1);
          }
        },
        error: function (error) {
          if (error.status === 400) {
            if (hasLike) that.removeClass('active');
            else that.addClass('active');
            if (error.responseJSON.fieldErrors) {
              var msg = error.responseJSON.fieldErrors.map(function (item) {
                return item.fieldError;
              }).join('/n');
              alert(msg);
            } else alert(error.responseJSON.msg);
          } else if (error.status === 403 || error.status === 401) {
            alert('로그인이 필요합니다.');
            window.location.href = '/login.do';
          }
        }
      });
    });
  });
  </c:if>
  $(function () {
      <c:if test="${not empty loginUser}">var userId = ${loginUser.id};
    </c:if>
      <c:if test="${empty loginUser}">var userId = null;
    </c:if>
    var page = 1;
    var sort = 'createdDate,desc';
    var $opinionList = $('#opinion-list');
    var $opinionMore = $('#opinion-more');
    var $opinionCount = $('#opinion-count');
    $('.opinion-sort').click(function (event) {
      event.preventDefault();
      var selectedSort = $(this).data('sort');

      $opinionList.css('height', $opinionList.height());
      $opinionList.text('');
      $('.comment-sorting-li').removeClass('active');
      $(this).parent('.comment-sorting-li').addClass('active');

      page = 1;
      sort = selectedSort;
      getOpinion();
    });

    $opinionMore.click(function () {
      page++;
      getOpinion();
    });

    function getOpinion() {
      $.ajax({
        headers: { 'X-CSRF-TOKEN': '${_csrf.token}' },
        url: '/ajax/opinions',
        contentType: 'application/json',
        data: {
          issueId: ${param.id},
          page: page,
          'sort[]': sort
        },
        success: function (data) {
          $opinionCount.text(data.totalElements);
          for (var i = 0; i < data.content.length; i++) {
            var content = makeOpinionString(data.content[i]);
            $opinionList.append(content);
          }
          $opinionList.css('height', 'auto');
          if (data.last) $opinionMore.addClass('hidden');
          else $opinionMore.removeClass('hidden');
        },
        error: function (error) {
          console.log(error);
        }
      });
    }

    function makeOpinionString(opinion) {
      var photo = opinion.createdBy.photo || '/images/noavatar.png';

      var ownerMenu = '';
      if(opinion.createdBy.id === userId) {
        ownerMenu = '        <div class="clearfix">' +
          '          <div class="pull-right">' +
          '            <button type="button" class="btn btn-default btn-sm edit-opinion-btn" data-id="' + opinion.id + '" data-content="' + opinion.content + '">수정하기</button>' +
          <%--'            <button type="button" class="btn btn-default btn-sm delete-opinion-btn" data-id="' + opinion.id + '">삭제하기</button>' + --%>
          '          </div>' +
          '        </div>';
      }

      return '<li class="comment-li">' +
        '      <div class="profile-circle profile-circle--comment" style="background-image: url(' + photo + ')">' +
        '        <p class="alt-text">' + opinion.createdBy.name + '사진</p>' +
        '      </div>' +
        '      <div class="comment-content">' +
        '        <div class="comment-info clearfix">' +
        '          <div class="comment-date-wrapper">' +
        '            <p class="comment-name">' + opinion.createdBy.name + '</p>' +
        '            <p class="comment-time"><i class="xi-time"></i> ' + opinion.createdDate.substring(0, opinion.createdDate.indexOf(' ')) + '</p>' +
        '          </div>' +
        '          <div class="comment-likes-count">' +
        '            <button class="opinion-thumbs-up-btn' + (opinion.liked ? ' active' : '') + '" data-id="' + opinion.id + '">' +
        '              <i class="xi-thumbs-up"></i> 공감 <strong>' + opinion.likeCount + '</strong>개' +
        '            </button>' +
        '          </div>' +
        '        </div>' +
        '        <p class="comment-content-text">' + opinion.content.replace(/\r\n|\r|\n|\n\r/g, '<br>') + '</p>' + ownerMenu +
        '      </div>' +
        '    </li>';
    }

    getOpinion();
  });
</script>