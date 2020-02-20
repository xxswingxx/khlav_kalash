// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
document.addEventListener("turbolinks:load", function() {
  
  // Early exit if the Stripe card Element is not present
  if (document.getElementById("card-element") == null) {
   return false;
  }

  var public_key = document.querySelector("meta[name='stripe-public-key']").content;
  var stripe = Stripe(public_key);
  var elements = stripe.elements();

  // Custom styling can be passed to options when creating an Element.
  var style = {
    base: {
      // Add your base input styles here. For example:
      fontSize: '16px',
      color: '#32325d',
    },
  };

  // Create an instance of the card Element
  var card = elements.create('card', {style: style});

  // Add an instance of the card Element into the `card-element` <div>
  card.mount('#card-element');

  var displayError = document.getElementById('card-errors');

  card.addEventListener('change', function(event) {
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });

  var form = document.getElementById('payment-form');
  var clientSecret = form.dataset.secret;

  form.addEventListener('submit', function(ev) {
    ev.preventDefault();
    stripe.confirmCardPayment(clientSecret, {
      payment_method: {
        card: card
      }
    }).then(function(result) {
      if (result.error) {
        // Show error to your customer (e.g., insufficient funds)
        displayError.textContent = result.error.message;
        console.log(result.error.message);
      } else {
        // The payment has been processed!
        if (result.paymentIntent.status === 'succeeded') {
          var hiddenInput = document.createElement('input');
          hiddenInput.setAttribute('type', 'hidden');
          hiddenInput.setAttribute('name', 'payment_intent');
          hiddenInput.setAttribute('value', result.paymentIntent.id);
          form.appendChild(hiddenInput);

          form.submit();
        }
      }
    });
  });
});