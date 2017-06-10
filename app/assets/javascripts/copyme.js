//Developed by Giri Annamalai M 
//This is simple jquery plugin to copy the text inside a text box or textarea.
//Its simple code to starters who want to create jquery plugins on their own.
//Happy Coding!
 
	$.fn.copyme = function() {
	 			$('span[id^="success-alert"]').remove();
	 				this.select();
	 				 $(this).focus();
                      document.execCommand("copy");
                     document.getSelection().removeAllRanges();
                 $(this).after('<span id="success-alert"><br>Copied to clipboard</span>');
    			$('#success-alert').css( "color", "green" );
	};
	
