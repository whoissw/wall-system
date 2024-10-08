$(document).ready(function () {
    window.addEventListener("message", function (event) {
        switch (event.data.action) {
            case "show":
                $("#configPanel").css("display", "flex");
                defineStatus();
                break;
            case "hide":
                $("#configPanel").css("display", "none");
                break;
        }
    });

    document.onkeyup = data => {
        if (data["key"] === "Escape") {
            $.post("https://wall/HideWall");
        }
    };

    $("#confirmBtn").on("click", function () {
        let maxDistance = $("#maxDistance").val();

        if (maxDistance > 475) {
            maxDistance = 475;
            $("#maxDistance").val(maxDistance);
        }

        const status = {
            maxDistance: maxDistance,
            id: $("#id").is(":checked"),
            source: $("#source").is(":checked"),
            names: $("#names").is(":checked"),
            jobs: $("#jobs").is(":checked"),
            health: $("#health").is(":checked"),
            vehicle: $("#vehicle").is(":checked"),
            lines: $("#lines").is(":checked")
        };

        $.post("https://wall/UpdateStatus", JSON.stringify(status), function (response) { });
    });

    $("#maxDistance").on("input", function () {
        let value = $(this).val();
        if (value > 475) {
            $(this).val(475);
        }
    });
});

function defineStatus() {
    $.post("https://wall/GetStatus", JSON.stringify({}), function (data) {
        $("#id").prop("checked", data.id);
        $("#source").prop("checked", data.source);
        $("#names").prop("checked", data.names);
        $("#jobs").prop("checked", data.jobs);
        $("#health").prop("checked", data.health);
        $("#vehicle").prop("checked", data.vehicle);
        $("#lines").prop("checked", data.lines);

        $("#maxDistance").val(data.maxDistance);
    });
}