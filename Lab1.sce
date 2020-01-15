experiments_number = 1000;
n = 1000;                   // количество шагов
realizations_number = 3;	// количество реализаций

left = -2.0;
right = +2.0;
omega = 1.5;

theory_variance = 4.0/3.0	// = 2/(alpha * alpha), где alpha = sqrt(6/2)

function x = generate_x()
    b = rand();	// равномерное распределение
    if (b < 0.5) then
        x = (2.0/sqrt(6.0)) * log(2.0 * b)
    else
        x = (-2.0/sqrt(6.0)) * log(2.0 - 2.0 * b)
    end
endfunction

function y = generate_y(left, right)
    y = rand() * (right - left) + left;
endfunction

// 1. Смоделировать и изобразить на графике несколько реализаций случайного процесса ξ(t), проведя дискретизацию параметра t.
function z = get_ksi(t, x, y, omega)	// случайный процесс:
    z = x * cos(omega * t) + y * sin(omega * t);
endfunction

// получить реализацию от left до right включительно с длиной шага (left - right / n):
function [t, z] = get_realization(x, y, omega, left, right) // возвращает t и z
    t = [left : (right - left) / n : right];                // задаётся одномерный массив (ОМ) t
    z = zeros(length(t), 1);                                // создание ОМ z длины ОМ t заполненого нулям
    for k = 1 : length(t)
        z(k) = get_ksi(t(k), x, y, omega);                  // заполнение ОМ z реализациями
    end
endfunction

// 2. Построить и изобразить графически статистические оценки математического ожидания и дисперсии случайного процесса ξ(t).
function [t, z] = estimate_mean()
    t = [left : (right - left) / n : right];
    z = zeros(length(t), 1);
    for i = 1 : length(t)
        for j = 1 : experiments_number
            z(i) = z(i) + get_ksi(t(i), generate_x(), generate_y(left, right), omega); // для конкретного времени t берём количество реализаций experiments_number и суммируем их
        end
        z(i) = z(i) / experiments_number; // и делим эту сумму на количество -- получаем статистическую оценку для конкретного времени t
    end // и так далее для всех остальных t
endfunction

function [t, z] = estimate_variance()
    t = [left : (right - left) / n : right];
    z = zeros(length(t), 1);
    for i = 1 : length(t)
        for j = 1 : experiments_number
            value = get_ksi(t(i), generate_x(), generate_y(left, right), omega);
            z(i) = z(i) + value * value;
        end
        z(i) = z(i) / (experiments_number - 1);
    end
endfunction

function [t, z] = estimate_correlation()
    t = [left : (right - left) / n : right];
    z = zeros(length(t), 1);
    for i = 1 : length(t)
        for j = 1 : experiments_number
            x = generate_x();
            y = generate_y(left, right);
            z(i) = z(i) + get_ksi(0.0, x, y, omega) * get_ksi(t(i), x, y, omega);
        end
        z(i) = z(i) / experiments_number;
    end
endfunction

function plot_realizations(number)
    scf();	// создаётся графическое окно
    for k = 1 : number
        [t, z] = get_realization(generate_x(), generate_y(left, right), omega, left, right);
        plot2d(t, z);
    end
endfunction

function plot_mean()
    [t, z] = estimate_mean()
    scf();
    plot2d(t, z);
    plot2d(t, zeros(length(t), 1), style = color('blue'), leg="реальное математическое ожидание");
endfunction

function plot_variance(theory_variance)
    [t, z] = estimate_variance()
    scf();
    plot2d(t, z);
    plot2d(t, theory_variance * ones(length(t), 1), style = color('blue'), leg="реальная дисперсия");
endfunction

function plot_correlation(theory_variance, omega)
    [t, z] = estimate_correlation()
    scf();
    plot2d(t, z);
    plot2d(t, theory_variance * cos(omega * t), style = color('blue'), leg="реальная корреляционная функция");
endfunction

plot_realizations(realizations_number);
plot_mean();
plot_variance(theory_variance);
plot_correlation(theory_variance, omega);