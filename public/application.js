$(document).ready(function(){
	player_hits();
  player_stays();
  dealer_hits();
});

function player_hits() {

	$(document).on("click", "form#hit_player input", function(){
    alert ("player hits!");
 		$.ajax({
			type : "POST",
      url: "/game/player/hit"
		}).done (function (msg){
      $("#game").replaceWith(msg);
    });
    return false;
	});
}

function player_stays() {
  $(document).on("click","form#stay_player input", function(){
    alert ("player stays!");
    $.ajax({
      type : "POST",
      url: "/game/player/stay"
    }).done(function (msg){
      $("#game").replaceWith(msg);
    });
    return false;
  });


}

function dealer_hits() {
  $(document).on("click","form#hit_dealer input",function(){

    alert ("dealer hits");
    $.ajax({
      type : "POST",
      url : "/game/dealer/hit"
    }).done (function (msg){
      $("#game").replaceWith(msg);
    });
    return false;
  });

}