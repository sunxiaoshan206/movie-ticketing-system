<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>发布影评</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="navbar">
        <h1>影评发布</h1>
        <div class="nav-links">
            <a href="index.jsp">首页</a>
            <a href="order.jsp">我的订单</a>
        </div>
    </div>
    
    <div class="container">
        <h2>为电影写影评</h2>
        
        <% 
            String movieName = request.getParameter("movie");
            if(movieName == null) movieName = "流浪地球";
        %>
        
        <div class="movie-info-small">
            <img src="https://via.placeholder.com/100x150" alt="海报">
            <div>
                <h3><%= movieName %></h3>
                <p>请分享你的观影感受</p>
            </div>
        </div>
        
        <form action="ReviewServlet" method="post" onsubmit="return submitReview()">
            <input type="hidden" name="movie" value="<%= movieName %>">
            
            <div class="form-group">
                <label>评分：</label>
                <div class="rating">
                    <% for(int i=1; i<=5; i++) { %>
                        <span class="star" onclick="setRating(<%= i %>)">☆</span>
                    <% } %>
                    <input type="hidden" name="rating" id="ratingValue" value="0">
                    <span id="ratingText">未评分</span>
                </div>
            </div>
            
            <div class="form-group">
                <label>影评标题：</label>
                <input type="text" name="title" placeholder="给影评选个标题">
            </div>
            
            <div class="form-group">
                <label>影评内容：</label>
                <textarea name="content" rows="6" placeholder="写下你的观影感受..."></textarea>
            </div>
            
            <button type="submit">发布影评</button>
        </form>
        
        <!-- 其他用户的影评 -->
        <h3>其他影评</h3>
        <div class="review-list">
            <div class="review-item">
                <div class="review-header">
                    <strong>用户A</strong>
                    <span class="stars">★★★★☆ 4.0</span>
                    <span class="date">2023-12-10</span>
                </div>
                <p class="review-title">非常震撼的科幻大片！</p>
                <p>特效很棒，剧情紧凑，中国科幻的里程碑之作。</p>
            </div>
            
            <div class="review-item">
                <div class="review-header">
                    <strong>用户B</strong>
                    <span class="stars">★★★☆☆ 3.0</span>
                    <span class="date">2023-12-08</span>
                </div>
                <p class="review-title">中规中矩</p>
                <p>特效不错，但剧情有些地方略显拖沓。</p>
            </div>
        </div>
    </div>
    
    <script>
        let currentRating = 0;
        
        function setRating(rating) {
            currentRating = rating;
            document.getElementById('ratingValue').value = rating;
            document.getElementById('ratingText').textContent = rating + '分';
            
            const stars = document.querySelectorAll('.star');
            stars.forEach((star, index) => {
                star.textContent = index < rating ? '★' : '☆';
                star.style.color = index < rating ? '#ffc107' : '#ccc';
            });
        }
        
        function submitReview() {
            if(currentRating === 0) {
                alert('请先评分！');
                return false;
            }
            alert('影评提交成功！');
            return true;
        }
    </script>
</body>
</html>