// Carrossel de Filmes em Destaque
document.addEventListener("DOMContentLoaded", function() {
  const carouselContainer = document.querySelector(".carousel-filmes");
  if (!carouselContainer) return;
  
  const prevBtn = document.querySelector(".carousel-prev");
  const nextBtn = document.querySelector(".carousel-next");
  
  if (!prevBtn || !nextBtn) return;
  
  const scrollAmount = 240;
  
  function scrollCarousel(direction) {
    const currentScroll = carouselContainer.scrollLeft;
    const targetScroll = direction === "next" ? currentScroll + scrollAmount : currentScroll - scrollAmount;
    
    carouselContainer.scrollTo({
      left: targetScroll,
      behavior: "smooth"
    });
    
    setTimeout(updateButtonStates, 300);
  }
  
  function updateButtonStates() {
    const maxScroll = carouselContainer.scrollWidth - carouselContainer.clientWidth;
    
    if (carouselContainer.scrollLeft <= 0) {
      prevBtn.style.opacity = "0.3";
      prevBtn.style.cursor = "not-allowed";
    } else {
      prevBtn.style.opacity = "1";
      prevBtn.style.cursor = "pointer";
    }
    
    if (carouselContainer.scrollLeft >= maxScroll - 1) {
      nextBtn.style.opacity = "0.3";
      nextBtn.style.cursor = "not-allowed";
    } else {
      nextBtn.style.opacity = "1";
      nextBtn.style.cursor = "pointer";
    }
  }
  
  prevBtn.addEventListener("click", function() {
    scrollCarousel("prev");
  });
  
  nextBtn.addEventListener("click", function() {
    scrollCarousel("next");
  });
  
  updateButtonStates();
  window.addEventListener("resize", updateButtonStates);
  
  let isDown = false;
  let startX;
  let scrollLeft;
  
  carouselContainer.addEventListener("mousedown", function(e) {
    isDown = true;
    carouselContainer.style.cursor = "grabbing";
    startX = e.pageX - carouselContainer.offsetLeft;
    scrollLeft = carouselContainer.scrollLeft;
  });
  
  carouselContainer.addEventListener("mouseleave", function() {
    isDown = false;
    carouselContainer.style.cursor = "grab";
  });
  
  carouselContainer.addEventListener("mouseup", function() {
    isDown = false;
    carouselContainer.style.cursor = "grab";
    updateButtonStates();
  });
  
  carouselContainer.addEventListener("mousemove", function(e) {
    if (!isDown) return;
    e.preventDefault();
    const x = e.pageX - carouselContainer.offsetLeft;
    const walk = (x - startX) * 2;
    carouselContainer.scrollLeft = scrollLeft - walk;
  });
  
  let touchStartX = 0;
  let touchEndX = 0;
  
  carouselContainer.addEventListener("touchstart", function(e) {
    touchStartX = e.changedTouches[0].screenX;
  }, { passive: true });
  
  carouselContainer.addEventListener("touchend", function(e) {
    touchEndX = e.changedTouches[0].screenX;
    handleSwipe();
  }, { passive: true });
  
  function handleSwipe() {
    const swipeThreshold = 50;
    if (touchStartX - touchEndX > swipeThreshold) {
      scrollCarousel("next");
    } else if (touchEndX - touchStartX > swipeThreshold) {
      scrollCarousel("prev");
    }
  }
});
