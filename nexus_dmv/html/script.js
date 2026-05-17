/**
 * DMV Driving School - JavaScript
 * Author: Ken Mondragon
 */

let currentTestType = null;

// ============================================
// MESSAGE HANDLER
// ============================================

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openVehicleSelection') {
        openVehicleSelection(data.testType, data.vehicles);
    } else if (data.action === 'openTheoryTest') {
        openTheoryTest(data.questions);
    } else if (data.action === 'closeTheoryTest') {
        closeTheoryTest();
    }
});

// ============================================
// VEHICLE SELECTION
// ============================================

function openVehicleSelection(testType, vehicles) {
    currentTestType = testType;
    
    const titles = {
        'drive': '  Select Your Car',
        'drive_bike': '  Select Your Motorcycle',
        'drive_truck': '  Select Your Truck'
    };
    
    $('#selectionTitle').text(titles[testType] || 'Select Your Vehicle');
    
    const vehicleGrid = $('#vehicleGrid');
    vehicleGrid.empty();
    
    if (!vehicles || !Array.isArray(vehicles) || vehicles.length === 0) {
        console.error('[DMV] No vehicles provided!');
        return;
    }
    
    vehicles.forEach(vehicle => {
        const card = `
            <div class="vehicle-card" data-model="${vehicle.model}">
                <img src="${vehicle.image}" class="vehicle-image" alt="${vehicle.name}" 
                     onerror="this.style.display='none'">
                <div class="vehicle-name">${vehicle.name}</div>
            </div>
        `;
        vehicleGrid.append(card);
    });
    
    $('#vehicle-selection').fadeIn(300);
}

function closeVehicleSelection() {
    $('#vehicle-selection').fadeOut(300);
    currentTestType = null;
}

 
$(document).on('click', '.vehicle-card', function() {
    const model = $(this).data('model');
    
    $.post('https://nexus_dmv/selectVehicle', JSON.stringify({
        testType: currentTestType,
        model: model
    }));
    
    closeVehicleSelection();
});

// Close button
$('#closeSelectionBtn').click(function() {
    $.post('https://nexus_dmv/closeVehicleSelection', JSON.stringify({}));
    closeVehicleSelection();
});

// ============================================
// THEORY TEST
// ============================================

let questions = [];
let currentQuestionIndex = 0;
let correctAnswers = 0;
let wrongAnswers = 0;
let isTestActive = false;

function openTheoryTest(receivedQuestions) {
    questions = receivedQuestions;
    currentQuestionIndex = 0;
    correctAnswers = 0;
    wrongAnswers = 0;
    isTestActive = true;
    
    $('#theory-test-container').fadeIn(300);
    $('#questionContainer').show();
    $('#resultContainer').hide();
    
    updateProgress();
    displayQuestion();
}

function closeTheoryTest() {
    $('#theory-test-container').fadeOut(300);
    isTestActive = false;
    questions = [];
    currentQuestionIndex = 0;
    correctAnswers = 0;
    wrongAnswers = 0;
}

function updateProgress() {
    const progress = ((currentQuestionIndex + 1) / questions.length) * 100;
    $('#progressBar').css('width', progress + '%');
    $('#currentQuestion').text(currentQuestionIndex + 1);
    $('#totalQuestions').text(questions.length);
}

function displayQuestion() {
    if (currentQuestionIndex >= questions.length) {
        showResults();
        return;
    }
    
    const question = questions[currentQuestionIndex];
    $('#questionText').text(question.question);
    
    $('.answer-btn').removeClass('correct wrong').prop('disabled', false);
}

function selectAnswer(answer) {
    const question = questions[currentQuestionIndex];
    const isCorrect = answer === question.answer;
    
    $('.answer-btn').prop('disabled', true);
    
    if (isCorrect) {
        correctAnswers++;
        if (answer) {
            $('#trueBtn').addClass('correct');
        } else {
            $('#falseBtn').addClass('correct');
        }
    } else {
        wrongAnswers++;
        if (answer) {
            $('#trueBtn').addClass('wrong');
        } else {
            $('#falseBtn').addClass('wrong');
        }
        
        setTimeout(() => {
            if (question.answer) {
                $('#trueBtn').addClass('correct');
            } else {
                $('#falseBtn').addClass('correct');
            }
        }, 300);
    }
    
    setTimeout(() => {
        currentQuestionIndex++;
        updateProgress();
        displayQuestion();
    }, 1500);
}

function showResults() {
    $('#questionContainer').hide();
    $('#resultContainer').fadeIn(300);
    
    const percentage = (correctAnswers / questions.length) * 100;
    const passed = correctAnswers === questions.length;
    
    // Update detailed stats
    $('#correctText').text(correctAnswers);
    $('#wrongText').text(wrongAnswers);
    $('#percentageText').text(Math.round(percentage) + '%');
    
    if (passed) {
        $('#resultIcon').html(' ');
        $('#resultTitle').text('Congratulations!').css('color', '#48bb78');
        $('#resultMessage').html('You passed the theory test!<br>You can now take the driving test.');
    } else {
        $('#resultIcon').html('  ');
        $('#resultTitle').text('Test Failed').css('color', '#f56565');
        $('#resultMessage').html('You need to answer all questions correctly.<br>Study the material and try again.');
    }
    
    $.post('https://nexus_dmv/theoryTestResult', JSON.stringify({
        passed: passed,
        correct: correctAnswers,
        wrong: wrongAnswers,
        total: questions.length,
        percentage: percentage
    }));
}

// ============================================
// EVENT HANDLERS
// ============================================

$(document).ready(function() {
     
    $('#trueBtn').click(function() {
        if (isTestActive && !$(this).prop('disabled')) {
            selectAnswer(true);
        }
    });
    
    $('#falseBtn').click(function() {
        if (isTestActive && !$(this).prop('disabled')) {
            selectAnswer(false);
        }
    });
    
    $('#finishBtn').click(function() {
        closeTheoryTest();
    });
    
     
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            if (isTestActive) {
                return;
            }
            if ($('#vehicle-selection').is(':visible')) {
                $.post('https://nexus_dmv/closeVehicleSelection', JSON.stringify({}));
                closeVehicleSelection();
            } else if ($('#theory-test-container').is(':visible')) {
                $.post('https://nexus_dmv/closeTheoryTest', JSON.stringify({}));
                closeTheoryTest();
            }
        }
    });
});
 
// ============================================
// RECEIPT VIEWER
// ============================================

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'openVehicleSelection') {
        openVehicleSelection(data.testType, data.vehicles);
    } else if (data.action === 'openTheoryTest') {
        openTheoryTest(data.questions);
    } else if (data.action === 'closeTheoryTest') {
        closeTheoryTest();
    } else if (data.action === 'showReceipt') {
        showReceipt(data.metadata);
    }
});

function showReceipt(metadata) {
    if (!metadata) return;
    
     
    $('#receiptPlayer').text(metadata.player || 'Unknown');
    $('#receiptTestType').text(metadata.type || 'Unknown Test');
    $('#receiptDate').text(metadata.date || 'N/A');
    
     
    if (metadata.correct !== undefined) {
        $('#receiptCorrect').text(metadata.correct);
        $('#receiptWrong').text(metadata.wrong);
        $('#receiptScore').text(metadata.correct + '/' + metadata.total);
        $('#receiptPercentage').text(metadata.percentage + '%');
        $('#receiptScoreSection').show();
    } else {
        $('#receiptScoreSection').hide();
    }
    
     
    const resultElement = $('#receiptResult');
    resultElement.text(metadata.result || 'N/A');
    
    if (metadata.result === 'PASSED') {
        resultElement.removeClass('failed').addClass('passed');
    } else {
        resultElement.removeClass('passed').addClass('failed');
    }
    
     
    $('#receipt-viewer').fadeIn(300);
}

function closeReceipt() {
    $('#receipt-viewer').fadeOut(300);
    $.post('https://nexus_dmv/closeReceipt', JSON.stringify({}));
}

 
$('#receiptCloseBtn').click(function() {
    closeReceipt();
});

 
$(document).keyup(function(e) {
    if (e.key === "Escape") {
        if ($('#receipt-viewer').is(':visible')) {
            closeReceipt();
        }
         
    }
});